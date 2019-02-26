using System.Collections.Generic;

namespace PolyPaint
{
    public class ChannelsMessage
    {
        public List<Channel> Channels { get; set; }
        public ChannelsMessage(List<Channel> channels)
        {
            Channels = channels;
        }
    }
}