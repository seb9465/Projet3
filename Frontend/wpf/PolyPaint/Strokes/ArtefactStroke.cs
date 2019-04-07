using PolyPaint.Utilitaires;
using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Linq;
using System.Collections.Concurrent;

namespace PolyPaint.Strokes
{
    public class ArtefactStroke : AbstractShapeStroke
    {
        public double ImageHeight { get; set; }
        public ArtefactStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(pts, surfaceDessin, "Artefact", couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            ImageHeight = UnrotatedHeight - 30;
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

            TopLeft = new Point(StylusPoints[0].X <= StylusPoints[1].X ? StylusPoints[0].X : StylusPoints[1].X,
                StylusPoints[0].Y <= StylusPoints[1].Y ? StylusPoints[0].Y : StylusPoints[1].Y);
            Width = Math.Abs(StylusPoints[1].X - StylusPoints[0].X);
            Height = Math.Abs(StylusPoints[1].Y - StylusPoints[0].Y);
            ImageHeight = UnrotatedHeight - 30;

            PointCollection points = new PointCollection();
            points.Add(UnrotatedTopLeft);
            points.Add(new Point(UnrotatedTopLeft.X + 5.0 / 6.0 * UnrotatedWidth, UnrotatedTopLeft.Y));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + 1.0 / 6.0 * ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + ImageHeight));
            points = new PointCollection(points.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)));

            StreamGeometry streamGeometry = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry.Open())
            {
                geometryContext.BeginFigure(points.First(), true, true);
                geometryContext.PolyLineTo(new PointCollection(points.Skip(1)), true, true);
            }

            Point intersection = Tools.RotatePoint(
                new Point(UnrotatedTopLeft.X + 5.0 / 6.0 * UnrotatedWidth, UnrotatedTopLeft.Y + 1.0 / 6.0 * ImageHeight),
                Center,
                Rotation
            );

            drawingContext.DrawGeometry(Fill, Border, streamGeometry);


            var cornerPoints = new Point[]
            {
                points[1],
                intersection,
                points[2]
            };
            DrawPolyline(drawingContext, null, Border, cornerPoints, FillRule.EvenOdd);

            if (IsDrawingDone)
            {
                drawingContext.PushTransform(new RotateTransform(Rotation, Center.X, Center.Y));
                DrawText(drawingContext);
                drawingContext.Pop();
            }
            DrawAnchorPoints(drawingContext);
        }

        private void DrawText(DrawingContext drawingContext)
        {
            drawingContext.DrawText(Title, new Point
            (
                UnrotatedTopLeft.X + UnrotatedWidth / 2.0 - Title.Width / 2.0,
                UnrotatedTopLeft.Y + ImageHeight + 10
            ));
        }

        protected override void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[AnchorPosition.Top] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y);
            AnchorPoints[AnchorPosition.Bottom] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y + ImageHeight);
            AnchorPoints[AnchorPosition.Right] = new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + ImageHeight / 2);
            AnchorPoints[AnchorPosition.Left] = new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + ImageHeight / 2.0);
            AnchorPoints = new ConcurrentDictionary<AnchorPosition, Point>
            (
                AnchorPoints.ToDictionary(x => x.Key, x => Tools.RotatePoint(x.Value, Center, Rotation))
            );

            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Top], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Bottom], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Right], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Left], 2, 2);
        }
    }
}
