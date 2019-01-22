using Microsoft.AspNetCore.SignalR;
using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;

namespace PolyPaint.Hubs
{
    public class PolyPaintHub : Hub
    {
        private readonly static ConcurrentDictionary<string, string> userIds =
            new ConcurrentDictionary<string, string>();

        public async Task SendMessage(string user, string message)
        {
            await Clients.All.SendAsync("ReceiveMessage", userIds[Context.ConnectionId], message);
        }

        public async Task SendToGroup(string groupId, string message)
        {
            await Clients.GroupExcept(groupId, Context.ConnectionId).SendAsync(message);
        }

        public override async Task OnConnectedAsync()
        {
            string username = Context.GetHttpContext().Request.Query["user"];
            if (username.Trim().Length != 0)
            {
                await base.OnConnectedAsync();
                userIds.GetOrAdd(Context.ConnectionId, username);
                await Groups.AddToGroupAsync(Context.ConnectionId, "test");
            }
        }

        public override async Task OnDisconnectedAsync(Exception e)
        {
            await base.OnDisconnectedAsync(e);
            await Clients.All.SendAsync("ReceiveMessage", "System", $"{userIds[Context.ConnectionId]} has disconnected");
            userIds.TryRemove(Context.ConnectionId, out var value);
        }
    }
}