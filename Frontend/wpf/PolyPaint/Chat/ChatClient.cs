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

        private readonly string _myAccessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImFsbG8iLCJuYW1laWQiOiI5MTk1Zjc1Ni1iZDIyLTQ1NjMtYmU5Zi00ZmMxNTI1ODEyNWEiLCJuYmYiOjE1NDg3Nzc4MzksImV4cCI6NjE1NDg3Nzc3NzksImlhdCI6MTU0ODc3NzgzOSwiaXNzIjoiMTAuMjAwLjI3LjE2OjUwMDEiLCJhdWQiOiIxMC4yMDAuMjcuMTY6NTAwMSJ9.CbbjkhbVk5ETsx-q-2CjEcGfUEM_Dzg22FQvnxmgtAg";

        public ChatClient()
        {
            connection =
                new HubConnectionBuilder()
                .WithUrl("https://localhost:44300/signalr", options =>
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

    }
}
