using Microsoft.AspNetCore.SignalR.Client;
using PolyPaint.Structures;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PolyPaint.Modeles
{
    class ChatClient
    {
        public event EventHandler MessageReceived;
        private HubConnection Connection { get; set; }

        public ChatClient()
        { }

        public async void Initialize(string accessToken)
        {
            Connection =
                new HubConnectionBuilder()
                .WithUrl("https://polypaint.me/signalr", options =>
                {
                    options.AccessTokenProvider = () => Task.FromResult(accessToken);
                })
                .Build();

            HandleMessages();
            await Connection.StartAsync();
            await Connection.InvokeAsync("ConnectToGroup", "");
        }

        private void HandleMessages()
        {
            Connection.On<string, string, string>("ReceiveMessage", (username, message, timestamp) =>
            {
                MessageReceived?.Invoke(this, new MessageArgs(username, message, timestamp));
            });
        }

        public async void SendMessage(string message)
        {
            await Connection.InvokeAsync("SendMessage", message);
        }
    }
}
