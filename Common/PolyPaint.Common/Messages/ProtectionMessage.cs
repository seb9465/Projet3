namespace PolyPaint.Common.Messages
{
    public class ProtectionMessage
    {
        public string ChannelId { get; set; }
        public bool IsProtected { get; set; }
        public ProtectionMessage(string channelId = "", bool isProtected = false)
        {
            ChannelId = channelId;
            IsProtected = isProtected;
        }
    }
}
