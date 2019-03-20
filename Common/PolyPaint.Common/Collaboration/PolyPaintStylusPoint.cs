using System;
using System.Windows.Input;

namespace PolyPaint.Common.Collaboration
{
    [Serializable]
    public class PolyPaintStylusPoint
    {
        public double X { get; set; }
        public double Y { get; set; }
        public float PressureFactor { get; set; }
    }
}
