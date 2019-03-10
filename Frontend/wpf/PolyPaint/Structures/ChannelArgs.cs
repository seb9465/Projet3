using System;

namespace PolyPaint.Structures
{
    class ChannelArgs : EventArgs
    {
        public Channel Channel { get; private set; }
        public ChannelArgs(Channel channel)
        {
            Channel = channel;
        }
    }
}
