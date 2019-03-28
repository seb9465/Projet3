using PolyPaint.Utilitaires;
using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class AgregationStroke : AbstractLineStroke
    {
        public AgregationStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, double tailleTrait)
            : base(pts, surfaceDessin, "0..0", "0..0", couleurBordure, "#00000000", tailleTrait, true)
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

            var unrotatedStp = Tools.RotatePoint(stp.ToPoint(), Center, -Rotation);
            var unrotatedSp = Tools.RotatePoint(sp.ToPoint(), Center, -Rotation);
            var unrotatedElbow = Tools.RotatePoint(LastElbowPosition, Center, -Rotation);

            int arrowLength = 10;
            double dx = unrotatedSp.X - unrotatedElbow.X;
            double dy = unrotatedSp.Y - unrotatedElbow.Y;

            double theta = Math.Atan2(dy, dx);

            double rad = (Math.PI / 180) * 35;
            double x = unrotatedSp.X - arrowLength * Math.Cos(theta + rad);
            double y = unrotatedSp.Y - arrowLength * Math.Sin(theta + rad);

            double phi2 = (Math.PI / 180) * -35;
            double x2 = unrotatedSp.X - arrowLength * Math.Cos(theta + phi2);
            double y2 = unrotatedSp.Y - arrowLength * Math.Sin(theta + phi2);

            double midX = (x2 + x) / 2;
            double midY = (y2 + y) / 2;

            PointCollection points = new PointCollection();
            points.Add(new Point(midX - (unrotatedSp.X - midX), midY - (unrotatedSp.Y - midY)));
            points.Add(new Point(x, y));
            points.Add(new Point(unrotatedSp.X, unrotatedSp.Y));
            points.Add(new Point(x2, y2));
            points.Add(new Point(midX - (unrotatedSp.X - midX), midY - (unrotatedSp.Y - midY)));
            points = new PointCollection(points.ToList().Select(point => Tools.RotatePoint(point, Center, Rotation)));
            
            StreamGeometry streamGeometry = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry.Open())
            {
                geometryContext.BeginFigure(points.First(), true, true);
                geometryContext.PolyLineTo(new PointCollection(points.Skip(1)), true, true);
            }

            drawingContext.DrawGeometry(null, Border, streamGeometry);

            var elbowPoints = new Point[]
            {
                stp.ToPoint(),
                LastElbowPosition,
                points[0]
            };
            DrawPolyline(drawingContext, null, Border, elbowPoints, FillRule.EvenOdd);
        }
    }
}
