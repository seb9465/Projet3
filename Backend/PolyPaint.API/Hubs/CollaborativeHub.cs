using Microsoft.AspNetCore.SignalR;
using Newtonsoft.Json;
using PolyPaint.API.Handlers;
using PolyPaint.Common;
using PolyPaint.Common.Collaboration;
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
    public class CollaborativeHub : BaseHub
    {
        public CollaborativeHub(UserService _userService) : base(_userService)
        { }

        public async Task Draw(string itemsMessage)
        {
            var message = JsonConvert.DeserializeObject<ItemsMessage>(itemsMessage);

            var user = await GetUserFromToken(Context.User);
            if (user != null && message.Items.Count > 0)
            {
                var channelId = message.CanvasId;
                if (UserHandler.UserGroupCollabMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    message.Username = user.UserName;
                    await Clients.OthersInGroup(channelId).SendAsync("Draw", JsonConvert.SerializeObject(message));
                }
            }
        }

        public async Task Cut(string itemsMessage)
        {
            var message = JsonConvert.DeserializeObject<ItemsMessage>(itemsMessage);

            var user = await GetUserFromToken(Context.User);
            if (user != null && message.Items.Count > 0)
            {
                var channelId = message.CanvasId;
                if (UserHandler.UserGroupCollabMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Cut", JsonConvert.SerializeObject(message));
                }
            }
        }

        public async Task Select(string itemsMessage)
        {
            var message = JsonConvert.DeserializeObject<ItemsMessage>(itemsMessage);

            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                var channelId = message.CanvasId;
                if (UserHandler.UserGroupCollabMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    message.Username = user.UserName;
                    await Clients.OthersInGroup(channelId).SendAsync("Select", JsonConvert.SerializeObject(message));
                }
            }
        }

        public async Task Reset()
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                if (UserHandler.TryGetByValueCollab(user, out var channelId))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Reset");
                }
            }
        }

        public override async Task OnConnectedAsync()
        {
            await base.OnConnectedAsync();
            var channelId = (string)Context.GetHttpContext().Request.Query["channelId"];
            await ConnectToChannel((new ConnectionMessage(channelId: channelId)).ToString());
        }

        public async Task ResizeCanvas(string sizeMessage)
        {
            var message = JsonConvert.DeserializeObject<SizeMessage>(sizeMessage);
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                if (UserHandler.TryGetByValueCollab(user, out var channelId))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("ResizeCanvas", JsonConvert.SerializeObject(message));
                }
            }
        }

        public override async Task ConnectToChannel(string message)
        {
            var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await AddToGroup(Context.ConnectionId, connectionMessage.ChannelId);
                UserHandler.AddOrUpdateCollabMap(connectionMessage.ChannelId, user.Id);
                var returnMessage = new ConnectionMessage(user.UserName, channelId: connectionMessage.ChannelId);
                await Clients.OthersInGroup(connectionMessage.ChannelId).SendAsync(
                    "ConnectToChannel",
                    returnMessage.ToString()
                );
                await Clients.Caller.SendAsync("ConnectToChannelSender", returnMessage.ToString());
            }
        }

        public async Task ChangeProtection(string protectionMessage)
        {
            var message = JsonConvert.DeserializeObject<ProtectionMessage>(protectionMessage);

            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                var channelId = message.ChannelId;
                if (UserHandler.UserGroupCollabMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    if (message.IsProtected)
                    {

                        await Clients.OthersInGroup(channelId).SendAsync("Kicked");
                        foreach (var other in UserHandler.UserConnections.Where(pair => pair.Value == channelId)
                            .Where(pair => pair.Key != Context.ConnectionId)
                            .Select(pair => pair.Key))
                        {
                            await RemoveFromGroup(other, channelId);
                        }
                    }
                    await Clients.OthersInGroup(channelId).SendAsync("ChangeProtection", message.ToString());
                }
            }
        }


        public override async Task DisconnectFromChannel(string message)
        {
            var connectionMessage = JsonConvert.DeserializeObject<ConnectionMessage>(message);
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                await RemoveFromGroup(Context.ConnectionId, connectionMessage.ChannelId);
                if (UserHandler.UserGroupCollabMap.TryGetValue(connectionMessage.ChannelId, out var list))
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

        public override async Task OnDisconnectedAsync(Exception e)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                foreach (var canvasId in _userService.GetAllCanvas().Select(x => x.CanvasId))
                {
                    await DisconnectFromChannel(new ConnectionMessage(user.UserName, channelId: canvasId).ToString());
                }
                await base.OnDisconnectedAsync(e);
            }
        }
    }
}