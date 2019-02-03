using System;

namespace PolyPaint.Structures
{
    class MessageArgs : EventArgs
    {
        public string Username { get; private set; }
        public string Message { get; private set; }
        public string Timestamp { get; private set; }
        public MessageArgs(string username, string message, string timestamp)
        {
            Message = message;
            Username = username;
            Timestamp = timestamp;
        }
    }
}
