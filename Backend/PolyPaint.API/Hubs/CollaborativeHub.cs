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
                var channelId = message.Items.First().ChannelId;
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Draw", JsonConvert.SerializeObject(itemsMessage));
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
        public async Task Delete(string channelId)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Delete");
                }
            }
        }


        public async Task Select(string itemsMessage)
        {
            var message = JsonConvert.DeserializeObject<ItemsMessage>(itemsMessage);

            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                var channelId = message.Items.First().ChannelId;
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Select", JsonConvert.SerializeObject(message));
                }
            }
        }

        public async Task Reset(string channelId)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Reset");
                }
            }
        }
    }
}