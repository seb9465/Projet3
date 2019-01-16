using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Net.WebSockets;
using System.Threading;
using System.Threading.Tasks;

namespace PolyPaint.WebSocketAPI
{
    public class WebSocketConnectionManager
    {
        private ConcurrentDictionary<string, WebSocket> Sockets { get; set; }
        private ConcurrentDictionary<string, List<string>> Groups { get; set; }

        public WebSocketConnectionManager()
        {
            Sockets = new ConcurrentDictionary<string, WebSocket>();
            Groups = new ConcurrentDictionary<string, List<string>>();
        }

        public WebSocket GetSocketById(string id)
        {
            return Sockets.FirstOrDefault(p => p.Key == id).Value;
        }

        public ConcurrentDictionary<string, WebSocket> GetAll()
        {
            return Sockets;
        }

        public List<string> GetAllFromGroup(string groupId)
        {
            if (Groups.ContainsKey(groupId))
            {
                return Groups[groupId];
            }

            return default(List<string>);
        }

        public string GetId(WebSocket socket)
        {
            return Sockets.FirstOrDefault(p => p.Value == socket).Key;
        }

        public string GetGroupBySocketId(string socketId)
        {
            return Groups.FirstOrDefault(x => x.Value.Contains(socketId)).Key;
        }

        public void AddSocket(WebSocket socket)
        {
            Sockets.TryAdd(CreateConnectionId(), socket);
        }

        public void AddToGroup(string socketId, string groupId)
        {
            if (Groups.ContainsKey(groupId))
            {
                Groups[groupId].Add(socketId);

                return;
            }

            Groups.TryAdd(groupId, new List<string> { socketId });
        }

        public async Task RemoveSocket(string id)
        {
            if (id == null) return;

            if (Groups.TryGetValue(GetGroupBySocketId(id), out var socketList))
            {
                socketList.Remove(id);
            }
            Sockets.TryRemove(id, out WebSocket socket);

            if (socket.State != WebSocketState.Open) return;

            await socket.CloseAsync(closeStatus: WebSocketCloseStatus.NormalClosure,
                                    statusDescription: "Closed by the WebSocketManager",
                                    cancellationToken: CancellationToken.None).ConfigureAwait(false);
        }

        public void RemoveFromGroup(string socketId, string groupId)
        {
            if (Groups.ContainsKey(groupId))
            {
                Groups[groupId].Remove(socketId);
            }
        }

        private string CreateConnectionId()
        {
            return Guid.NewGuid().ToString();
        }
    }
}