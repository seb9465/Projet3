using PolyPaint.Common;
using System.Collections.Generic;


namespace PolyPaint.VueModeles
{
    public class DrawViewModel
    {
        public ItemTypeEnum ItemType { get; set; }
        public List<PolyPaintStylusPoint> StylusPoints { get; set; }
        public string OutilSelectionne { get; set; }
        public PolyPaintColor Color { get; set; }
    }
}
