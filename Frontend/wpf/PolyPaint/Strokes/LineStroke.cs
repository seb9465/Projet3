using PolyPaint.Utilitaires;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class LineStroke : Stroke, ICanvasable
    {
        public InkCanvas SurfaceDessin { get; set; }
        public Point MiddlePoint { get; set; }
        public LineStroke(StylusPointCollection pts, InkCanvas surfaceDessin)
            : base(pts)
        {
            StylusPoints = pts;
            MiddlePoint = new Point((pts[1].X + pts[0].X) / 2, (pts[1].Y + pts[0].Y) / 2);

            SurfaceDessin = surfaceDessin;
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
            Pen pen = new Pen(brush, 2);
            brush.Freeze();
            StylusPoint stp = StylusPoints[0];
            StylusPoint sp = StylusPoints[1];

            drawingContext.DrawLine(pen, new Point(sp.X, sp.Y), new Point(stp.X, stp.Y));

            SolidColorBrush pointBrush = new SolidColorBrush(Colors.Gray);
            drawingContext.DrawEllipse(pointBrush, null, MiddlePoint, 2, 2);
        }

        public void AddToCanvas()
        {
            RemoveFromCanvas();
            SurfaceDessin.Strokes.Add(Clone());
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
        }

        public void Redraw()
        {
            OnInvalidated(new EventArgs());
        }
    }
}
