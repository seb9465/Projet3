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

                if (UserHandler.UserGroupMap.TryGetValue(chatMessage.ChannelId, out var users) && users.Contains(user.Id))
                {
                    // Maybe change in a way that it doesnt send back to sender (sender handles his own message in the ui)
                    await Clients.Group(chatMessage.ChannelId).SendAsync("SendMessage",
                        new ChatMessage(user.UserName, chatMessage.Message, chatMessage.ChannelId, timestamp)
                    );
                }
            }
        }

        public async Task FetchChannels()
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                List<Channel> list = UserHandler.UserGroupMap.Select(x => new Channel(x.Key, x.Value.Contains(user.Id))).ToList();
                ChannelsMessage channelsMessage = new ChannelsMessage(list);
                await Clients.Caller.SendAsync("FetchChannels", channelsMessage);
            }
        }

        public async Task CreateChannel(ChannelMessage channelMessage)
        {

            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                UserHandler.AddOrUpdateMap(channelMessage.Channel.Name, user.Id);
                await Clients.Caller.SendAsync("CreateChannel", channelMessage);
            }
        }

        public async Task ConnectToChannel(ConnectionMessage connectionMessage)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, connectionMessage.ChannelId);
                UserHandler.AddOrUpdateMap(connectionMessage.ChannelId, user.Id);
                var message = new ConnectionMessage(user.UserName, channelId: connectionMessage.ChannelId);
                await Clients.Group(connectionMessage.ChannelId).SendAsync(
                    "ConnectToChannel",
                    message
                );
                await Clients.Caller.SendAsync("ConnectToChannelSender", message);
            }
        }

        public async Task DisconnectFromChannel(ConnectionMessage connectionMessage)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, connectionMessage.ChannelId);
                if (UserHandler.UserGroupMap.TryGetValue(connectionMessage.ChannelId, out var list))
                {
                    list.Remove(user.Id);
                    var message = new ConnectionMessage(username: user.UserName, channelId: connectionMessage.ChannelId);
                    await Clients.Group(connectionMessage.ChannelId).SendAsync(
                        "DisconnectFromChannel",
                        message
                    );
                    await Clients.Caller.SendAsync("DisconnectFromChannelSender", message);
                }
            }
        }

        public override async Task OnConnectedAsync()
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await base.OnConnectedAsync();
                await ConnectToChannel(new ConnectionMessage(channelId: "general"));
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
                        await Clients.Group(pair.Key).SendAsync(
                            "DisconnectFromChannel",
                            new ConnectionMessage(username: user.UserName)
                        );
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