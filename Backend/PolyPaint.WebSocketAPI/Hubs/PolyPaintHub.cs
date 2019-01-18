using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace PolyPaint.Hubs
{
    public class PolyPaintHub : Hub
    {
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
            await base.OnConnectedAsync();
            await Groups.AddToGroupAsync(Context.ConnectionId, "test");
        }
    }
}