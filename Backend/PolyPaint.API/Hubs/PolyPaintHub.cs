using Microsoft.AspNetCore.SignalR;
using PolyPaint.DataStructures;
using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;

namespace PolyPaint.Hubs
{
    public class PolyPaintHub : Hub
    {
        private readonly static ConcurrentDictionary<string, ConnectionInfo> userIds =
            new ConcurrentDictionary<string, ConnectionInfo>();

        public async Task SendMessage(string user, string message)
        {
            var groupId = userIds[Context.ConnectionId].GroupId;
            if (groupId != null)
            {
                await Clients.Group(groupId).SendAsync("ReceiveMessage", userIds[Context.ConnectionId].Username, message);
            }
        }

        public async Task ConnectToGroup(string groupId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, groupId);
            userIds[Context.ConnectionId].GroupId = groupId;
        }

        public async Task SendToGroup(string message)
        {
            var groupId = userIds[Context.ConnectionId].GroupId;
            if (groupId != null)
            {
                await Clients.Group(groupId).SendAsync(message);
            }
        }

        public override async Task OnConnectedAsync()
        {
            string username = Context.GetHttpContext().Request.Query["user"];
            if (username.Trim().Length != 0)
            {
                await base.OnConnectedAsync();
                var connInfo = new ConnectionInfo(username, null);
                userIds.GetOrAdd(Context.ConnectionId, connInfo);
            }
        }

        public override async Task OnDisconnectedAsync(Exception e)
        {
            await base.OnDisconnectedAsync(e);
            await Clients.All.SendAsync("ReceiveMessage", "System", $"{userIds[Context.ConnectionId].Username} has disconnected");
            userIds.TryRemove(Context.ConnectionId, out var value);
        }
    }
}