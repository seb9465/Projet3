using PolyPaint.Utilitaires;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class AnchorPointStroke : Stroke, ICanvasable
    {
        public InkCanvas SurfaceDessin { get; set; }

        public AnchorPointStroke(StylusPointCollection pts, InkCanvas surfaceDessin)
            : base(pts)
        {
            StylusPoints = pts;

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
            SolidColorBrush brush = new SolidColorBrush(Colors.Red);
            brush.Freeze();

            Point topLeft = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            double width = (StylusPoints[1].X - StylusPoints[0].X);
            double height = (StylusPoints[1].Y - StylusPoints[0].Y);

            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X + width / 2, topLeft.Y), 2, 2);
            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X + width / 2, topLeft.Y + height), 2, 2);
            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X + width, topLeft.Y + height / 2), 2, 2);
            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X, topLeft.Y + height / 2), 2, 2);
        }

        public void AddToCanvas()
        {
            SurfaceDessin.Strokes.Add(Clone());
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
        }
    }
}
