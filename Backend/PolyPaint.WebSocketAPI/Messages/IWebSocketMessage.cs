namespace PolyPaint.WebSocketAPI.Messages
{
    public interface IWebSocketMessage
    {
        MessageType Type { get; }
        string ToString();
    }
}
