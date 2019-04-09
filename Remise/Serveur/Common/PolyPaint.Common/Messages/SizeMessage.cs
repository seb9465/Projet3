using PolyPaint.Common.Collaboration;

namespace PolyPaint.Common.Messages
{
    public class SizeMessage
    {
        public PolyPaintStylusPoint Size { get; set; }
        public SizeMessage(PolyPaintStylusPoint size)
        {
            Size = size;
        }
    }
}
