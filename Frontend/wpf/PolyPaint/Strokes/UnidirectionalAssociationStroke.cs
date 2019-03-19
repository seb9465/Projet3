using PolyPaint.Utilitaires;
using System;
using System.Drawing.Drawing2D;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class UnidirectionalAssociationStroke : Stroke, ICanvasable
    {
        public InkCanvas SurfaceDessin { get; set; }
        public UnidirectionalAssociationStroke(StylusPointCollection pts, InkCanvas surfaceDessin)
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
            SolidColorBrush brush = new SolidColorBrush(drawingAttributes.Color);
            Pen pen = new Pen(brush, 2);
            StylusPoint stp = StylusPoints[0];
            StylusPoint sp = StylusPoints[1];

            int arrowLength = 10;
            double dx = sp.X - stp.X;
            double dy = sp.Y - stp.Y;

            double theta = Math.Atan2(dy, dx);

            double rad = (Math.PI / 180) * 35;
            double x = sp.X - arrowLength * Math.Cos(theta + rad);
            double y = sp.Y - arrowLength * Math.Sin(theta + rad);

            double phi2 = (Math.PI / 180) * -35;
            double x2 = sp.X - arrowLength * Math.Cos(theta + phi2);
            double y2 = sp.Y - arrowLength * Math.Sin(theta + phi2);

            Point point2 = new Point(sp.X, sp.Y);
            Point point3 = new Point(x, y);
            Point point4 = new Point(sp.X, sp.Y);
            Point point5 = new Point(x2, y2);
            Point point6 = new Point(sp.X, sp.Y);
            StreamGeometry streamGeometry = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry.Open())
            {
                geometryContext.BeginFigure(stp.ToPoint(), true, true);
                PointCollection points = new PointCollection
                                             {
                                                 point2,
                                                 point3,
                                                 point4,
                                                 point5,
                                                 point6
                                             };
                geometryContext.PolyLineTo(points, true, true);
            }

            drawingContext.DrawGeometry(brush, pen, streamGeometry);
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
