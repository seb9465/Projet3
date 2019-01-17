using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.WebSockets;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using PolyPaint.WebSocketAPI.Messages;

namespace PolyPaint.WebSocketAPI
{
    public class PolyPaintWebSocketHandler : WebSocketHandler
    {

        public PolyPaintWebSocketHandler(WebSocketConnectionManager webSocketConnectionManager)
            : base(webSocketConnectionManager) { }

        public override async void OnConnected(WebSocket socket, string token)
        {
            base.OnConnected(socket, token);

            // Do something with token like
            // Add connection entry to DB
            // Link socket to user in DB

            var socketId = WebSocketConnectionManager.GetId(socket);
            WebSocketConnectionManager.AddToGroup(socketId, "testGroup");

            await SendMessageAsync(socketId, "connected");
        }

        public override Task ReceiveAsync(WebSocket socket, WebSocketReceiveResult result, byte[] buffer)
        {
            string received = "";
            var socketId = WebSocketConnectionManager.GetId(socket);
            try
            {
                received = Encoding.UTF8.GetString(buffer, 0, result.Count);
                IWebSocketMessage message = JsonConvert.DeserializeObject<BaseWebSocketMessage>(received);

                switch (message.Type)
                {
                    case MessageType.Default:
                        // Default type: to test
                        SendMessageAsync(socket, "message received").Wait();
                        break;
                    case MessageType.Chat:
                        var groupId = WebSocketConnectionManager.GetGroupBySocketId(socketId);
                        var response = new ChatMessage(socketId, (message as BaseWebSocketMessage).Data);
                        SendMessageToGroupAsync(groupId, (response as IWebSocketMessage).ToString(), socketId).Wait();
                        break;
                    default:
                        SendMessageAsync(socket, new ErrorMessage("Not implemented").ToString()).Wait();
                        throw new NotImplementedException();
                }
            }
            catch (Newtonsoft.Json.JsonReaderException)
            {
                SendMessageAsync(socket, "Error deserializing message: JSON expected").Wait();
            }
            catch (Newtonsoft.Json.JsonSerializationException)
            {
                SendMessageAsync(socket, "Error deserializing message: JSON expected").Wait();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.WriteLine(ex.GetType().ToString());
                Console.WriteLine(received);
            }

            return Task.CompletedTask;
        }
    }
}
