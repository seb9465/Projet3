using Microsoft.AspNetCore.SignalR;
using PolyPaint.API.Handlers;
using PolyPaint.DataAccess.Services;
using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PolyPaint.API.Hubs
{
    public class PolyPaintHub : Hub
    {
        private readonly int MAX_USERS_PER_GROUP = 4;
        private readonly UserService _userService;

        public PolyPaintHub(UserService userService)
        {
            _userService = userService;
        }

        public async Task SendMessage(string message)
        {
            if (_userService.TryGetUserId(Context.User, out var userId))
            {
                var user = await _userService.FindByIdAsync(userId);

                if (user != null && UserHandler.UserGroupMap.TryGetValue(userId, out var groupId))
                {
                    // Maybe change in a way that it doesnt send back to sender (sender handles his own message in the ui)
                    await Clients.Group(groupId).SendAsync("ReceiveMessage", user.FullName(), message);
                }
            }
        }

        public async Task ConnectToGroup(string groupId)
        {
            if (_userService.TryGetUserId(Context.User, out var userId))
            {
                var user = await _userService.FindByIdAsync(userId);
                var userCountInGroup = UserHandler.UserGroupMap.Values.Count(x => x == groupId);
                
                if (user != null && userCountInGroup < MAX_USERS_PER_GROUP)
                {
                    await Groups.AddToGroupAsync(Context.ConnectionId, groupId);
                    UserHandler.UserGroupMap.AddOrUpdate(user.Id, groupId, (k, v) => groupId);
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
                    UserHandler.UserGroupMap.GetOrAdd(userId, (string)null);
                }
            }
        }

        public override async Task OnDisconnectedAsync(Exception e)
        {
            if (_userService.TryGetUserId(Context.User, out var userId))
            {
                var user = await _userService.FindByIdAsync(userId);
                await base.OnDisconnectedAsync(e);

                if (user != null && UserHandler.UserGroupMap.TryRemove(userId, out var groupId))
                {
                    await Clients.Group(groupId).SendAsync("ReceiveMessage", null, $"{user.FullName()} has disconnected");
                }
            }
        }
    }
}