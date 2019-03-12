public class ChatMessage : BaseMessage
{
    public string Username { get; set; }
    public string Message { get; set; }
    public string ChannelId { get; set; }
    public string Timestamp { get; set; }
    public ChatMessage(string username = "", string message = "", string channelId = "", string timestamp = "")
    {
        Username = username;
        Message = message;
        ChannelId = channelId;
        Timestamp = timestamp;
    }
}
