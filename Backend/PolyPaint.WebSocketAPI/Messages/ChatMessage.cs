namespace PolyPaint.WebSocketAPI.Messages
{
    public class ChatMessage : BaseWebSocketMessage
    {
        public string From { get; private set; }

        public ChatMessage(string from, string data = "") : base(MessageType.Chat, data)
        {
            From = from;
        }
    }
}
        