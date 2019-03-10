using System.Collections.Generic;

public class ChannelsMessage : BaseMessage
{
    public List<Channel> Channels {get;set;}
    public ChannelsMessage(List<Channel> channels)
    {
        Channels = channels;
    }
}