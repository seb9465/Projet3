using PolyPaint.Utilitaires;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Linq;
using System.Collections.Concurrent;

namespace PolyPaint.Strokes
{
    public class RoleStroke : AbstractShapeStroke
    {
        public double ImageHeight { get; set; }
        public RoleStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(pts, surfaceDessin, "Role", couleurBordure, couleurRemplissage, thicc, dashStyle)
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

            var head = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 1.0 / 8.0 * ImageHeight);
            head = Tools.RotatePoint(head, Center, Rotation);
            var rotatedWidth = Rotation / 90.0 % 2 == 0 ? 1.0 / 4.0 * Width : 1.0 / 8.0 * (Width - 30);
            var rotatedHeight = Rotation / 90.0 % 2 == 0 ? 1.0 / 8.0 * (Height - 30) : 1.0 / 4.0 * Height;

            PointCollection points = new PointCollection();
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 1.0 / 4.0 * ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 3.0 / 4.0 * ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + 3.0 / 8.0 * ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + 3.0 / 8.0 * ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 3.0 / 4.0 * ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 3.0 / 4.0 * ImageHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + ImageHeight));
            points = new PointCollection(points.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)));

            drawingContext.DrawEllipse(Fill, Border, head, rotatedWidth, rotatedHeight);
            drawingContext.DrawLine(Border, points[0], points[1]);
            drawingContext.DrawLine(Border, points[2], points[3]);
            drawingContext.DrawLine(Border, points[4], points[5]);
            drawingContext.DrawLine(Border, points[6], points[7]);

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
            drawingContext.DrawText(Title, new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0 - Title.Width / 2.0, UnrotatedTopLeft.Y + ImageHeight + 10));
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
