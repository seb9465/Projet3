using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class PhaseStroke : AbstractShapeStroke
    {
        public PhaseStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc)
            : base(pts, surfaceDessin, "Phase", couleurBordure, couleurRemplissage, thicc)
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

            drawingContext.DrawRectangle(Fill, Border, new Rect(TopLeft, new Point(TopLeft.X + Width, TopLeft.Y + Title.Height + 20)));
            drawingContext.DrawRectangle(Brushes.Transparent, Border, new Rect(new Point(TopLeft.X, TopLeft.Y + Title.Height + 20), new Point(TopLeft.X + Width, TopLeft.Y + Height)));

            if (IsDrawingDone)
                DrawText(drawingContext, Title);
            DrawAnchorPoints(drawingContext);
        }

        private void DrawText(DrawingContext drawingContext, FormattedText Title)
        {
            drawingContext.DrawText(Title, new Point(TopLeft.X + Width / 2.0 - Title.Width / 2.0, TopLeft.Y + 10));
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[0] = new Point(TopLeft.X + Width / 2, TopLeft.Y);
            AnchorPoints[1] = new Point(TopLeft.X + Width / 2, TopLeft.Y + Height);
            AnchorPoints[2] = new Point(TopLeft.X + Width, TopLeft.Y + Height / 2);
            AnchorPoints[3] = new Point(TopLeft.X, TopLeft.Y + Height / 2);

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 2, 2);

        }
    }
}
