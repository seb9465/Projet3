using PolyPaint.Utilitaires;
using System;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class ActivityStroke : AbstractShapeStroke
    {
        public ActivityStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(pts, surfaceDessin, "Activity", couleurBordure, couleurRemplissage, thicc, dashStyle)
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

            PointCollection points = new PointCollection();
            points.Add(UnrotatedTopLeft);
            points.Add(new Point(UnrotatedTopLeft.X + 5.0 / 6.0 * UnrotatedWidth, UnrotatedTopLeft.Y));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2.0));
            points.Add(new Point(UnrotatedTopLeft.X + 5.0 / 6.0 * UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X + 1.0 / 6.0 * UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2.0));
            points = new PointCollection(points.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)));

            StreamGeometry streamGeometry = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry.Open())
            {
                geometryContext.BeginFigure(points.First(), true, true);
                geometryContext.PolyLineTo(new PointCollection(points.Skip(1)), true, true);
            }

            drawingContext.DrawGeometry(Fill, Border, streamGeometry);

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
                UnrotatedTopLeft.Y + UnrotatedHeight + 10
            ));
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[0] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y);
            AnchorPoints[1] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y + UnrotatedHeight);
            AnchorPoints[2] = new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2);
            AnchorPoints[3] = new Point(UnrotatedTopLeft.X + 1.0 / 6.0 * UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2.0);
            AnchorPoints = AnchorPoints.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)).ToArray();

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 3, 3);
        }
    }
}
