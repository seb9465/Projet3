using Microsoft.AspNetCore.SignalR;
using PolyPaint.API.Handlers;
using PolyPaint.Core;
using PolyPaint.DataAccess.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PolyPaint.API.Hubs
{
    public class ChatHub : Hub
    {
        private readonly UserService _userService;

        public ChatHub(UserService userService)
        {
            _userService = userService;
        }

        public async Task SendMessage(ChatMessage chatMessage)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null && chatMessage.Message.Trim().Length != 0)
            {
                var timestamp = DateTime.Now.ToString("HH:mm:ss");

                if (UserHandler.UserGroupMap.TryGetValue(chatMessage.ChannelId, out var users))
                {
                    if (users.Contains(user.Id))
                    {
                        // Maybe change in a way that it doesnt send back to sender (sender handles his own message in the ui)
                        await Clients.Group(chatMessage.ChannelId).SendAsync("ChatMessage",
                            new ChatMessage(user.UserName, chatMessage.Message, chatMessage.ChannelId, timestamp)
                        );
                    }
                }
            }
        }

        public async Task ConnectToGroup(string groupId = "general")
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, groupId);
                UserHandler.UserGroupMap.AddOrUpdate(groupId, new List<string>() { user.Id }, (k, v) =>
                {
                    v.Add(user.Id);
                    return v;
                });
                await Clients.Group(groupId).SendAsync("SystemMessage", $"{user.UserName} just connected");
            }
        }

        public override async Task OnConnectedAsync()
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await base.OnConnectedAsync();
                await ConnectToGroup();
                await Clients.Caller.SendAsync("ClientIsConnected", "You are connected!");
            }
        }

        public override async Task OnDisconnectedAsync(Exception e)
        {
            if (_userService.TryGetUserId(Context.User, out var userId))
            {
                var user = await _userService.FindByIdAsync(userId);
                await base.OnDisconnectedAsync(e);

                foreach (var pair in UserHandler.UserGroupMap.Where(x => x.Value.Contains(user.Id)))
                {
                    if (user != null)
                    {
                        pair.Value.Remove(user.Id);
                        await Clients.Group(pair.Key).SendAsync("SystemMessage", $"{user.UserName} has disconnected");
                    }
                }
            }
        }

        private async Task<ApplicationUser> GetUserFromToken(ClaimsPrincipal contextUser)
        {
            string userId;
            if (_userService.TryGetUserId(contextUser, out userId))
            {
                var user = await _userService.FindByIdAsync(userId);
                if (user != null)
                {
                    return user;
                }
                else
                {
                    await Clients.Caller.SendAsync("ErrorMessage",
                        new ErrorMessage("Error occured while looking for user")
                    );
                    return null;
                }
            }
            else
            {
                await Clients.Caller.SendAsync("ErrorMessage",
                    new ErrorMessage("Error occured while looking for token")
                );
                return null;
            }
        }
    }
}