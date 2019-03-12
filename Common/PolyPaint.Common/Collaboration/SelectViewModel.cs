using System;
using System.Collections.Generic;
using System.Text;

namespace PolyPaint.Common.Collaboration
{
    public class SelectViewModel
    {
        public string Owner { get; set; }
        public double MouseLeftDownPointX { get; set; }
        public double MouseLeftDownPointY { get; set; }
        public string ChannelId { get; set; } = "general";

    }
}
