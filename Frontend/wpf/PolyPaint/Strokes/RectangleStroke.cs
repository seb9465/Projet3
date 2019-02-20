using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class RectangleStroke : Stroke
    {
        public RectangleStroke(StylusPointCollection pts)
            : base(pts)
        {
            this.StylusPoints = pts;
        }

        protected override void DrawCore(DrawingContext drawingContext, DrawingAttributes drawingAttributes)
        {
            if (drawingContext == null)
            {
                throw new ArgumentNullException("drawingContext");
            }
            if (null == drawingAttributes)
            {
                throw new ArgumentNullException("drawingAttributes");
            }
            SolidColorBrush brush = new SolidColorBrush(drawingAttributes.Color);
            brush.Freeze();
            StylusPoint stp = this.StylusPoints[0];
            StylusPoint sp = this.StylusPoints[1];
            drawingContext.DrawRectangle(brush, null, new Rect(new Point(sp.X, sp.Y), new Point(stp.X, stp.Y)));
        }
    }
}
