using PolyPaint.Utilitaires;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class InheritanceStroke : AbstractLineStroke
    {
        public InheritanceStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure)
            : base(pts, surfaceDessin, "0..0", "0..0", couleurBordure, "#00000000")
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

            AttachToAnchors();

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

            Point point2 = new Point((x2 + x) / 2,(y2 + y) / 2);
            Point point3 = new Point(x, y);
            Point point4 = new Point(sp.X, sp.Y);
            Point point5 = new Point(x2, y2);
            Point point6 = new Point((x2 + x) / 2, (y2 + y) / 2);
            StreamGeometry streamGeometry = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry.Open())
            {
                geometryContext.BeginFigure(point2, true, true);
                PointCollection points = new PointCollection
                                             {
                                                 point3,
                                                 point4,
                                                 point5,
                                                 point6
                                             };
                geometryContext.PolyLineTo(points, true, true);
            }

            drawingContext.DrawGeometry(Fill, Border, streamGeometry);
            drawingContext.DrawLine(Border, stp.ToPoint(), point2);
        }
    }
}
