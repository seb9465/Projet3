public class ChannelMessage : BaseMessage
{
    public Channel Channel { get; set; }
    public ChannelMessage(Channel channel)
    {
        Channel = channel;
    }
}