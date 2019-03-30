using Microsoft.AspNetCore.SignalR;
using Newtonsoft.Json;
using PolyPaint.API.Handlers;
using PolyPaint.Common;
using PolyPaint.Common.Collaboration;
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

        public async Task Draw(string canvasDrawings)
        {
            var drawViewModels = JsonConvert.DeserializeObject<List<DrawViewModel>>(canvasDrawings);

            var user = await GetUserFromToken(Context.User);
            if (user != null && drawViewModels.Count > 0)
            {
                var channelId = drawViewModels.First().ChannelId;
                if (UserHandler.UserGroupMap.TryGetValue(channelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(channelId).SendAsync("Draw", JsonConvert.SerializeObject(drawViewModels));
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


        public async Task Select(SelectViewModel selectViewModel)
        {
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                if (UserHandler.UserGroupMap.TryGetValue(selectViewModel.ChannelId, out var users) && users.Contains(user.Id))
                {
                    await Clients.OthersInGroup(selectViewModel.ChannelId).SendAsync("Select", selectViewModel);
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