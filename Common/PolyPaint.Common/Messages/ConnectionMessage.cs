namespace PolyPaint.Common.Messages
{
    public class ConnectionMessage : BaseMessage
    {
        public string Username { get; set; }
        public string CanvasId { get; set; }
        public string ChannelId { get; set; }

        public ConnectionMessage(string username = "", string canvasId = "", string channelId = "")
        {
            Username = username;
            CanvasId = canvasId;
            ChannelId = channelId;
        }
    }
}