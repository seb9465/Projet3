using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using Microsoft.AspNetCore.SignalR.Client;


namespace PolyPaint.Chat
{
    public class ChatClient
    {
        public HubConnection connection;

        public ChatClient()
        {
            connection = 
                new HubConnectionBuilder()
                .WithUrl("http://localhost:5000/signalr?user=JaiLdouaJsuisMecanicien")
                .Build();

            connection.Closed += async (error) =>
            {
                await Task.Delay(new Random().Next(0, 5) * 1000);
                await connection.StartAsync();
            };
        }

        public async void SendMessage(string message)
        {
            await connection.InvokeAsync("SendMessage", "user1", message);
        }
    }
}
