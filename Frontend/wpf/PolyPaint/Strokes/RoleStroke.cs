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

namespace PolyPaint.Strokes
{
    public class RoleStroke : AbstractShapeStroke
    {
        public RoleStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(pts, surfaceDessin, "Role", couleurBordure, couleurRemplissage, thicc, dashStyle)
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

            var head = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 1.0 / 8.0 * UnrotatedHeight);
            head = Tools.RotatePoint(head, Center, Rotation);
            var rotatedWidth = Rotation / 90.0 % 2 == 0 ? 1.0 / 4.0 * Width : 1.0 / 8.0 * Width;
            var rotatedHeight = Rotation / 90.0 % 2 == 0 ? 1.0 / 8.0 * Height : 1.0 / 4.0 * Height;

            PointCollection points = new PointCollection();
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 1.0 / 4.0 * UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 3.0 / 4.0 * UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + 3.0 / 8.0 * UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + 3.0 / 8.0 * UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 3.0 / 4.0 * UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0, UnrotatedTopLeft.Y + 3.0 / 4.0 * UnrotatedHeight));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight));
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
            drawingContext.DrawText(Title, new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0 - Title.Width / 2.0, TopLeft.Y + UnrotatedHeight + 10));
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[0] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y);
            AnchorPoints[1] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y + UnrotatedHeight);
            AnchorPoints[2] = new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2);
            AnchorPoints[3] = new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + UnrotatedHeight / 2);
            AnchorPoints = AnchorPoints.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)).ToArray();

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 2, 2);

        }
    }
}
