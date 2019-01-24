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
            var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _userService.FindByIdAsync(userId);
            // var groupId = UserHandler.UserGroupMap[userId];
            var groupId = UserHandler.UserGroupMap[user.Id];

            if (user != null && groupId != null)
            {
                await Clients.Group(groupId).SendAsync("ReceiveMessage", user.FullName(), message);
            }
        }

        public async Task ConnectToGroup(string groupId)
        {
            var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _userService.FindByIdAsync(userId);

            var userCountInGroup = UserHandler.UserGroupMap.Values.Count(x => x == groupId);
            if (user != null && userCountInGroup < MAX_USERS_PER_GROUP)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, groupId);
                UserHandler.UserGroupMap.AddOrUpdate(user.Id, groupId, (k, v) => groupId );
                // UserHandler.UserGroupMap[user.Id] = groupId;
            }
        }

        public override async Task OnConnectedAsync()
        {
            var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _userService.FindByIdAsync(userId);

            if (user != null)
            {
                await base.OnConnectedAsync();
                // UserHandler.UserGroupMap.GetOrAdd(userId, (string)null);
                UserHandler.UserGroupMap.GetOrAdd(user.Id, (string)null);
            }
        }

        public override async Task OnDisconnectedAsync(Exception e)
        {
            var userId = Context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _userService.FindByIdAsync(userId);
            // var groupId = UserHandler.UserGroupMap[userId];
            var groupId = UserHandler.UserGroupMap[user.Id];

            await base.OnDisconnectedAsync(e);
            // UserHandler.UserGroupMap.TryRemove(userId, out var value);
            UserHandler.UserGroupMap.TryRemove(user.Id, out var value);
            if (user != null && groupId != null)
            {
                await Clients.Group(groupId).SendAsync("ReceiveMessage", null, $"{user.FullName()} has disconnected");
            }
        }
    }
}