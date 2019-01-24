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

        private readonly string _myAccessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImFsZXhpc2xvaXNlbGxlIiwibmFtZWlkIjoiYzNkYWUwYzctNTFhNy00MWE4LTg0ZDYtODZkNzI0OTEwMzgyIiwibmJmIjoxNTQ4MzUwMzEzLCJleHAiOjYxNTQ4MzUwMjUzLCJpYXQiOjE1NDgzNTAzMTMsImlzcyI6IjEwLjIwMC4yNy4xNjo1MDAxIiwiYXVkIjoiMTAuMjAwLjI3LjE2OjUwMDEifQ.zMJ2HAeaAk0P07ut9DoCFjR28WT8A3uO1a9Y8vvMmTs";

        public ChatClient()
        {
            connection =
                new HubConnectionBuilder()
                .WithUrl("http://localhost:4000/signalr", options =>
                {
                    options.AccessTokenProvider = () => Task.FromResult(_myAccessToken);
                })
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
