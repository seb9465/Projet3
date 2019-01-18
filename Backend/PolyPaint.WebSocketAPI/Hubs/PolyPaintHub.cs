using Microsoft.AspNetCore.SignalR;
using System.Collections.Concurrent;
using System.Threading.Tasks;

namespace PolyPaint.Hubs
{
    public class PolyPaintHub : Hub
    {
        private ConcurrentDictionary<string, string> userIds { get; set; }
        public async Task SendMessage(string user, string message)
        {
            await Clients.All.SendAsync("ReceiveMessage", user, message);
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
                userIds.AddOrUpdate(Context.ConnectionId, username, (key, old) => username);
                await Groups.AddToGroupAsync(Context.ConnectionId, "test");
            }
        }
    }
}