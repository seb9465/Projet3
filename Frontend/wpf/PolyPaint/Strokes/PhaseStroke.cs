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
    public class PhaseStroke : AbstractStroke, ICanvasable, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        public string Title { get; set; }

        public InkCanvas SurfaceDessin { get; set; }

        public PhaseStroke(StylusPointCollection pts, InkCanvas surfaceDessin)
            : base(pts)
        {
            StylusPoints = pts;
            Title = "Class";

            SurfaceDessin = surfaceDessin;
            AnchorPoints = new Point[4];
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
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

            var brush = Brushes.Blue;
            var pen = new Pen(Brushes.HotPink, 2);
            var ft = new FormattedText(Title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);

            StylusPoint stp = StylusPoints[0];
            StylusPoint sp = StylusPoints[1];

            var topLeft = new Point(StylusPoints[0].X <= StylusPoints[1].X ? StylusPoints[0].X : StylusPoints[1].X,
                StylusPoints[0].Y <= StylusPoints[1].Y ? StylusPoints[0].Y : StylusPoints[1].Y);
            double width = Math.Abs(StylusPoints[1].X - StylusPoints[0].X);
            double height = Math.Abs(StylusPoints[1].Y - StylusPoints[0].Y);

            drawingContext.DrawRectangle(brush, pen, new Rect(topLeft, new Point(topLeft.X + width, topLeft.Y + ft.Height + 20)));
            drawingContext.DrawRectangle(Brushes.Transparent, pen, new Rect(new Point(topLeft.X, topLeft.Y + ft.Height + 20), new Point(topLeft.X + width, topLeft.Y + height)));

            if (IsDrawingDone)
                DrawText(drawingContext, ft);
            DrawAnchorPoints(drawingContext);
        }

        private void DrawText(DrawingContext drawingContext, FormattedText ft)
        {
            //var topLeft = new Point(StylusPoints[0].X <= StylusPoints[1].X ? StylusPoints[0].X : StylusPoints[1].X,
            //    StylusPoints[0].Y <= StylusPoints[1].Y ? StylusPoints[0].Y : StylusPoints[1].Y);
            //double width = Math.Abs(StylusPoints[1].X - StylusPoints[0].X);
            //double height = Math.Abs(StylusPoints[1].Y - StylusPoints[0].Y);

            //var nextHeight = topLeft.Y + 10;

            //var ft = new FormattedText(Title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, new SolidColorBrush(Colors.Black));
            //drawingContext.DrawText(ft, new Point(topLeft.X + 10, nextHeight));
            //nextHeight += 10 + ft.Height;
            //drawingContext.DrawLine(new Pen(new SolidColorBrush(Colors.Black), 1), new Point(topLeft.X, nextHeight), new Point(topLeft.X + width, nextHeight));
            //nextHeight += 10;
            //for (int i = 0; i < Properties.Count; i++)
            //{
            //    var tempFt = new FormattedText($"{Properties[i].Title}", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, new SolidColorBrush(Colors.Black));
            //    drawingContext.DrawText(tempFt, new Point(topLeft.X + 10, nextHeight));
            //    nextHeight += 10 + tempFt.Height;
            //}
            //drawingContext.DrawLine(new Pen(new SolidColorBrush(Colors.Black), 1), new Point(topLeft.X, nextHeight), new Point(topLeft.X + width, nextHeight));
            //nextHeight += 10;
            //for (int i = 0; i < Methods.Count; i++)
            //{
            //    var tempFt = new FormattedText($"{Methods[i].Title}", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, new SolidColorBrush(Colors.Black));
            //    drawingContext.DrawText(tempFt, new Point(topLeft.X + 10, nextHeight));
            //    nextHeight += 10 + tempFt.Height;
            //}
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            Point topLeft = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            double width = (StylusPoints[1].X - StylusPoints[0].X);
            double height = (StylusPoints[1].Y - StylusPoints[0].Y);

            AnchorPoints[0] = new Point(topLeft.X + width / 2, topLeft.Y);
            AnchorPoints[1] = new Point(topLeft.X + width / 2, topLeft.Y + height);
            AnchorPoints[2] = new Point(topLeft.X + width, topLeft.Y + height / 2);
            AnchorPoints[3] = new Point(topLeft.X, topLeft.Y + height / 2);

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 2, 2);

        }

        public void AddToCanvas()
        {
            var clone = Clone();
            (clone as AbstractStroke).IsDrawingDone = true;
            SurfaceDessin.Strokes.Add(clone);
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
        }
    }
}
