using PolyPaint.Common;
using System;
using System.Collections.Generic;


namespace PolyPaint.Common.Collaboration
{
    [Serializable]
    public class DrawViewModel
    {
        public string Owner { get; set; }
        public ItemTypeEnum ItemType { get; set; }
        public List<PolyPaintStylusPoint> StylusPoints { get; set; }
        public PolyPaintColor FillColor { get; set; }
        public PolyPaintColor BorderColor { get; set; }
        public double BorderThickness { get; set; }
        public string ShapeTitle { get; set; }
        public List<string> Methods { get; set; }
        public List<string> Properties { get; set; }
        public string SourceTitle { get; set; }
        public string DestinationTitle { get; set; }
        public string ChannelId { get; set; } = "general";
        public string OutilSelectionne { get; set; }
        public PolyPaintStylusPoint LastElbowPosition { get; set; }
        public byte[] ImageBytes { get; set; }
    }
}
