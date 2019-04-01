using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class LineStroke : AbstractLineStroke
    {
        public LineStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, double thicc, DashStyle dashStyle)
            : base(pts, surfaceDessin, "0..0", "0..0", couleurBordure, "#FF000000", thicc, false, dashStyle)
        { }

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

            TopLeft = new Point(StylusPoints[0].X <= StylusPoints[1].X ? StylusPoints[0].X : StylusPoints[1].X,
                StylusPoints[0].Y <= StylusPoints[1].Y ? StylusPoints[0].Y : StylusPoints[1].Y);
            Width = Math.Abs(StylusPoints[1].X - StylusPoints[0].X);
            Height = Math.Abs(StylusPoints[1].Y - StylusPoints[0].Y);

            var pts = AttachToAnchors();

            StylusPoint stp = pts[0];
            StylusPoint sp = pts[1];

            var elbowPoints = new Point[]
            {
                stp.ToPoint(),
                LastElbowPosition,
                sp.ToPoint()
            };
            DrawPolyline(drawingContext, null, Border, elbowPoints, FillRule.EvenOdd);
        }
    }
}
