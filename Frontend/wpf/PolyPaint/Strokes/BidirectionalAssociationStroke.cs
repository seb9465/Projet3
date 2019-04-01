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
    public class BidirectionalAssociationStroke : AbstractLineStroke
    {
        public BidirectionalAssociationStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, double thicc, DashStyle dashStyle)
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

            var unrotatedStp = Tools.RotatePoint(stp.ToPoint(), Center, -Rotation);
            var unrotatedSp = Tools.RotatePoint(sp.ToPoint(), Center, -Rotation);
            var unrotatedElbow = Tools.RotatePoint(LastElbowPosition, Center, -Rotation);

            int arrowLength = 10;
            double rad = (Math.PI / 180) * 35;
            double phi2 = (Math.PI / 180) * -35;

            double startDx = unrotatedStp.X - unrotatedElbow.X;
            double startDy = unrotatedStp.Y - unrotatedElbow.Y;
            double startTheta = Math.Atan2(startDy, startDx);

            double startX = unrotatedStp.X - arrowLength * Math.Cos(startTheta + rad);
            double startY = unrotatedStp.Y - arrowLength * Math.Sin(startTheta + rad);

            double startX2 = unrotatedStp.X - arrowLength * Math.Cos(startTheta + phi2);
            double startY2 = unrotatedStp.Y - arrowLength * Math.Sin(startTheta + phi2);

            double endDx = unrotatedSp.X - unrotatedElbow.X;
            double endDy = unrotatedSp.Y - unrotatedElbow.Y;
            double endTheta = Math.Atan2(endDy, endDx);

            double endX = unrotatedSp.X - arrowLength * Math.Cos(endTheta + rad);
            double endY = unrotatedSp.Y - arrowLength * Math.Sin(endTheta + rad);

            double endX2 = unrotatedSp.X - arrowLength * Math.Cos(endTheta + phi2);
            double endY2 = unrotatedSp.Y - arrowLength * Math.Sin(endTheta + phi2);


            PointCollection points = new PointCollection();
            points.Add(unrotatedStp);
            points.Add(new Point(startX, startY));
            points.Add(new Point(unrotatedStp.X, unrotatedStp.Y));
            points.Add(new Point(startX2, startY2));
            points.Add(unrotatedSp);
            points.Add(new Point(endX, endY));
            points.Add(new Point(unrotatedSp.X, unrotatedSp.Y));
            points.Add(new Point(endX2, endY2));
            points = new PointCollection(points.ToList().Select(point => Tools.RotatePoint(point, Center, Rotation)));

            StreamGeometry streamGeometry1 = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry1.Open())
            {
                geometryContext.BeginFigure(points[0], true, true);
                var newPoints = new PointCollection
                {
                    points[1],
                    points[2],
                    points[3]
                };
                geometryContext.PolyLineTo(newPoints, true, true);
            }

            StreamGeometry streamGeometry2 = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry2.Open())
            {
                geometryContext.BeginFigure(points[4], true, true);
                var newPoints = new PointCollection
                {
                    points[5],
                    points[6],
                    points[7]
                };
                geometryContext.PolyLineTo(newPoints, true, true);
            }

            drawingContext.DrawGeometry(Fill, Border, streamGeometry1);
            drawingContext.DrawGeometry(Fill, Border, streamGeometry2);

            var elbowPoints = new Point[]
            {
                stp.ToPoint(),
                LastElbowPosition,
                sp.ToPoint()
            };
            DrawPolyline(drawingContext, null, Border, elbowPoints, FillRule.EvenOdd);
            DrawText(drawingContext);
        }
    }
}
