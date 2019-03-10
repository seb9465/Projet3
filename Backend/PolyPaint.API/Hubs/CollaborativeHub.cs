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

        public CollaborativeHub(UserService userService): base(userService)
        {
        }

        public async Task Draw(string canvasDrawing)
        {
            var drawViewModel = JsonConvert.DeserializeObject<DrawViewModel>(canvasDrawing);
            var user = await GetUserFromToken(Context.User);
            if (user != null)
            {
                if (UserHandler.UserGroupMap.TryGetValue(drawViewModel.ChannelId, out var users) && users.Contains(user.Id))
                {
                    var returnDrawViewModel = new DrawViewModel();
                    await Clients.Group(drawViewModel.ChannelId).SendAsync("Draw", returnDrawViewModel.ToString());
                }
            }
        }
    }
}