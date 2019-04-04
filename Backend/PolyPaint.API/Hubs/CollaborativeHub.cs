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
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Draw", JsonConvert.SerializeObject(message));
                }
            }
        }

        /*    public async Task Duplicate()
            {
                var user = await GetUserFromToken(Context.User);
                if (user != null)
                {
                    await Clients.Group(groupId).SendAsync("Duplicate");
                }
            }
            */
        public async Task Cut(string itemsMessage)
        {
            var message = JsonConvert.DeserializeObject<ItemsMessage>(itemsMessage);

            var user = await GetUserFromToken(Context.User);
            if (user != null && message.Items.Count > 0)
            {
                var channelId = message.CanvasId;
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
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
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
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
                if (UserHandler.TryGetByValue(user, out var channelId))
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
                if (UserHandler.TryGetByValue(user, out var channelId))
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
                await Groups.AddToGroupAsync(Context.ConnectionId, connectionMessage.ChannelId);
                UserHandler.AddOrUpdateMap(connectionMessage.ChannelId, user.Id);
                var returnMessage = new ConnectionMessage(user.UserName, channelId: connectionMessage.ChannelId);
                await Clients.OthersInGroup(connectionMessage.ChannelId).SendAsync(
                    "ConnectToChannel",
                    returnMessage.ToString()
                );
                await Clients.Caller.SendAsync("ConnectToChannelSender", returnMessage.ToString());
            }
        }
    }
}