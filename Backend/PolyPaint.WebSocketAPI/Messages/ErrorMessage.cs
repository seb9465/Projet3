namespace PolyPaint.WebSocketAPI.Messages
{
    public class ErrorMessage : BaseWebSocketMessage
    {
        public string From { get; private set; }

        public ErrorMessage(string data = "") : base(MessageType.Error, data) { }
    }
}
