using System;
using System.Net.WebSockets;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using PolyPaint.WebSocketAPI.Messages;

namespace PolyPaint.WebSocketAPI
{
    public class WebSocketManagerMiddleware
    {
        private readonly RequestDelegate _next;
        private WebSocketHandler WebSocketHandler { get; set; }

        public WebSocketManagerMiddleware(RequestDelegate next,
                                          WebSocketHandler webSocketHandler)
        {
            _next = next;
            WebSocketHandler = webSocketHandler;
        }

        public async Task Invoke(HttpContext context)
        {
            if (!context.WebSockets.IsWebSocketRequest)
                return;

            bool isClose;
            var socket = await context.WebSockets.AcceptWebSocketAsync();
            if (context.Request.Query.TryGetValue("token", out var value))
            {
                Console.WriteLine($"Value: {value}");
                WebSocketHandler.OnConnected(socket, value);
                isClose = false;

                await Receive(socket, async (result, buffer) =>
                {
                    if (result.MessageType == WebSocketMessageType.Text)
                    {
                        await WebSocketHandler.ReceiveAsync(socket, result, buffer);
                        return;
                    }

                    else if (result.MessageType == WebSocketMessageType.Close)
                    {
                        await WebSocketHandler.OnDisconnected(socket);
                        isClose = true;
                        return;
                    }

                });
            }
            else
            {
                var errorMessage = new ErrorMessage("No token provided");
                WebSocketHandler.SendMessageAsync(socket, errorMessage.ToString()).Wait();
                isClose = true;
            }

            if (!isClose)
            {
                await _next.Invoke(context);
            }
        }

        private async Task Receive(WebSocket socket, Action<WebSocketReceiveResult, byte[]> handleMessage)
        {
            var buffer = new byte[1024 * 4];

            while (socket.State == WebSocketState.Open)
            {
                var result = await socket.ReceiveAsync(buffer: new ArraySegment<byte>(buffer),
                                                       cancellationToken: CancellationToken.None);

                handleMessage(result, buffer);
            }
        }
    }
}
