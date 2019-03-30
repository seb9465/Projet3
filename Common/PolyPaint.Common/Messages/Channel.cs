namespace PolyPaint.Common.Messages
{
    public class Channel
    {
        public string Name;
        public bool Connected;
        public Channel(string name, bool connected)
        {
            Name = name;
            Connected = connected;
        }
    }
}