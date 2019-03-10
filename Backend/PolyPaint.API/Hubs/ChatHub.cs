using Microsoft.AspNetCore.SignalR;
using Newtonsoft.Json;
using PolyPaint.API.Handlers;
using PolyPaint.Core;
using PolyPaint.DataAccess.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PolyPaint.API.Hubs
{
    public class ChatHub : BaseHub
    {

        public ChatHub(UserService userService): base(userService)
        {
        }

        public async Task SendMessage(string message)
        {
            var chatMessage = JsonConvert.DeserializeObject<ChatMessage>(message);
            var user = await GetUserFromToken(Context.User);
            if (user != null && chatMessage.Message.Trim().Length != 0)
            {
                var timestamp = DateTime.Now.ToString("HH:mm:ss");

                if (UserHandler.UserGroupMap.TryGetValue(chatMessage.ChannelId, out var users) && users.Contains(user.Id))
                {
                    // Maybe change in a way that it doesnt send back to sender (sender handles his own message in the ui)
                    var returnMessage = new ChatMessage(user.UserName, chatMessage.Message, chatMessage.ChannelId, timestamp);
                    await Clients.Group(chatMessage.ChannelId).SendAsync("SendMessage",
                        returnMessage.ToString()
                    );
                }
            }
        }
    }
}