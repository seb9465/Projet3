using System;

namespace PolyPaint.Structures
{
    public class MessageArgs : EventArgs
    {
        public string Username { get; private set; }
        public string Message { get; private set; }
        public string Timestamp { get; private set; }
        public string ChannelId { get; private set; }
        public MessageArgs(string username = "", string message = "", string timestamp = "", string channelId = "")
        {
            Message = message;
            Username = username;
            Timestamp = timestamp;
            ChannelId = channelId;
        }
    }
}
