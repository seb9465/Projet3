using PolyPaint.Common;
using System.Collections.Generic;


namespace PolyPaint.Common.Collaboration
{
    public class DrawViewModel
    {
        public string Owner { get; set; }
        public ItemTypeEnum ItemType { get; set; }
        public List<PolyPaintStylusPoint> StylusPoints { get; set; }
        public string OutilSelectionne { get; set; }
        public PolyPaintColor Color { get; set; }
        public string ChannelId { get; set; } = "general";
    }
}
