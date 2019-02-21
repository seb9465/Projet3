using Microsoft.AspNetCore.SignalR;
using PolyPaint.API.Handlers;
using PolyPaint.DataAccess.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PolyPaint.API.Hubs
{
    public class CollaborativeHub : Hub
    {
        private readonly UserService _userService;
        private readonly int MAX_USERS_PER_GROUP = 4;
        public CollaborativeHub(UserService userService)
        {
            _userService = userService;
        }


        public async Task ConnectToGroup(string groupId = "collaborative")
        {
            if (_userService.TryGetUserId(Context.User, out var userId))
            {
                var user = await _userService.FindByIdAsync(userId);
                var userCountInGroup = UserHandler.UserGroupMap.Values.Count(x => x == groupId);
                if (user != null && userCountInGroup < MAX_USERS_PER_GROUP)
                {
                    await Groups.AddToGroupAsync(Context.ConnectionId, groupId);
                    UserHandler.UserGroupMap.AddOrUpdate(user.Id, groupId, (k, v) => groupId);
                    await Clients.Group(groupId).SendAsync("SystemMessage", $"{user.UserName} just connected");
                }
            }
        }

        public override async Task OnConnectedAsync()
        {
            if (_userService.TryGetUserId(Context.User, out var userId))
            {
                var user = await _userService.FindByIdAsync(userId);
                if (user != null)
                {
                    await base.OnConnectedAsync();
                    UserHandler.UserGroupMap.GetOrAdd(userId, "collaborative");
                    await Clients.Caller.SendAsync("ClientIsConnected", "You are connected!");
                }
            }
        }
    }
}
