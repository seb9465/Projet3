public class ChannelMessage
{
    public Channel Channel { get; set; }
    public ChannelMessage(Channel channel)
    {
        Channel = channel;
    }
}