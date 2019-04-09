using Microsoft.AspNetCore.SignalR;
using Newtonsoft.Json;
using PolyPaint.API.Handlers;
using PolyPaint.Common;
using PolyPaint.Common.Messages;
using PolyPaint.Core;
using PolyPaint.DataAccess.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;


namespace PolyPaint.API.Hubs
{
    public class BaseHub : Hub
    {
        internal readonly UserService _userService;

        public BaseHub(UserService userService)
        {
            _userService = userService;
        }

        public async Task FetchChannels()
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                List<Channel> list = UserHandler.UserGroupMap.Select(x => new Channel(x.Key, x.Value.Contains(user.Id))).ToList();
                ChannelsMessage channelsMessage = new ChannelsMessage(list);
                await Clients.Caller.SendAsync("FetchChannels", channelsMessage.ToString());
            }
        }

        public async Task CreateChannel(string message)
        {
            var channelMessage = JsonConvert.DeserializeObject<ChannelMessage>(message);
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                UserHandler.AddOrUpdateMap(channelMessage.Channel.Name, user.Id);
                await Clients.All.SendAsync("CreateChannel", channelMessage.ToString());
            }
        }

        public virtual async Task ConnectToChannel(string message)
        {
            var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await AddToGroup(Context.ConnectionId, connectionMessage.ChannelId);
                UserHandler.AddOrUpdateMap(connectionMessage.ChannelId, user.Id);
                var returnMessage = new ConnectionMessage(user.UserName, channelId: connectionMessage.ChannelId);
                await Clients.Group(connectionMessage.ChannelId).SendAsync(
                    "ConnectToChannel",
                    returnMessage.ToString()
                );
                await Clients.Caller.SendAsync("ConnectToChannelSender", returnMessage.ToString());
            }
        }

        protected async Task AddToGroup(string connectionId, string channelId)
        {
            await Groups.AddToGroupAsync(connectionId, channelId);
            UserHandler.AddOrUpdateConnectionMap(connectionId, channelId);
        }

        public virtual async Task DisconnectFromChannel(string message)
        {
            var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await RemoveFromGroup(Context.ConnectionId, connectionMessage.ChannelId);
                if (UserHandler.UserGroupMap.TryGetValue(connectionMessage.ChannelId, out var list))
                {
                    list.Remove(user.Id);
                    var returnMessage = new ConnectionMessage(username: user.UserName, channelId: connectionMessage.ChannelId);
                    await Clients.Group(connectionMessage.ChannelId).SendAsync(
                        "DisconnectFromChannel",
                        returnMessage.ToString()
                    );
                    await Clients.Caller.SendAsync("DisconnectFromChannelSender", returnMessage.ToString());
                }
            }
        }

        protected async Task RemoveFromGroup(string connectionId, string channelId)
        {
            await Groups.RemoveFromGroupAsync(connectionId, channelId);
            UserHandler.UserConnections.Remove(connectionId, out var _);
        }

        public override async Task OnConnectedAsync()
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await base.OnConnectedAsync();
            }
        }

        public override async Task OnDisconnectedAsync(Exception e)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                foreach (var group in UserHandler.UserGroupMap.Where(pair => pair.Value.Contains(user.Id)))
                {
                    group.Value.Remove(user.Id);
                    await RemoveFromGroup(Context.ConnectionId, group.Key);
                }
                await base.OnDisconnectedAsync(e);
            }
        }

        internal async Task<ApplicationUser> GetUserFromToken(ClaimsPrincipal contextUser)
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
                    var message = new ErrorMessage("Error occured while looking for user");
                    await Clients.Caller.SendAsync("ErrorMessage",
                        message.ToString()
                    );
                    return null;
                }
            }
            else
            {
                var message = new ErrorMessage("Error occured while looking for token");
                await Clients.Caller.SendAsync("ErrorMessage",
                    message.ToString()
                );
                return null;
            }
        }
    }
}
