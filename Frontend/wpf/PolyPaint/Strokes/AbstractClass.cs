using System;
using System.Collections.Generic;
using System.Windows;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Ink;
using System.Windows.Input;

namespace PolyPaint.Strokes
{
    public abstract class AbstractStroke : Stroke
    {
        public Point[] AnchorPoints;
        public bool IsDrawingDone = false;

        public AbstractStroke(StylusPointCollection stylusPoints) : base(stylusPoints)
        {

        }
    }
}