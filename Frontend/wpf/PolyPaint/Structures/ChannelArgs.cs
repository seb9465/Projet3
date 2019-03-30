using System;

namespace PolyPaint.Structures
{
    public class ChannelArgs : EventArgs
    {
        public Channel Channel { get; private set; }
        public ChannelArgs(Channel channel)
        {
            Channel = channel;
        }
    }
}
