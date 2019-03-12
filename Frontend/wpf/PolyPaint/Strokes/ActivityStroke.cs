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
    public class ActivityStroke : AbstractStroke, ICanvasable, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        public string Title { get; set; }

        public InkCanvas SurfaceDessin { get; set; }

        public ActivityStroke(StylusPointCollection pts, InkCanvas surfaceDessin)
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
            StylusPoint stp = StylusPoints[0];
            StylusPoint sp = StylusPoints[1];

            var topLeft = new Point(StylusPoints[0].X <= StylusPoints[1].X ? StylusPoints[0].X : StylusPoints[1].X,
                StylusPoints[0].Y <= StylusPoints[1].Y ? StylusPoints[0].Y : StylusPoints[1].Y);
            double width = Math.Abs(StylusPoints[1].X - StylusPoints[0].X);
            double height = Math.Abs(StylusPoints[1].Y - StylusPoints[0].Y);

            Point point2 = new Point(topLeft.X + 5.0 / 6.0 * width, topLeft.Y);
            Point point3 = new Point(topLeft.X + width, topLeft.Y + height / 2.0);
            Point point4 = new Point(topLeft.X + 5.0 / 6.0 * width, topLeft.Y + height);
            Point point5 = new Point(topLeft.X, topLeft.Y + height);
            Point point6 = new Point(topLeft.X + 1.0 / 6.0 * width, topLeft.Y + height / 2.0);
            StreamGeometry streamGeometry = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry.Open())
            {
                geometryContext.BeginFigure(topLeft, true, true);
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

            // CHANGE TO PARAMETERS' COLORS
            drawingContext.DrawGeometry(Brushes.Blue, new Pen(Brushes.Black, 2), streamGeometry);

            if (IsDrawingDone)
                DrawText(drawingContext);
            DrawAnchorPoints(drawingContext);
        }

        private void DrawText(DrawingContext drawingContext)
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
            AnchorPoints[3] = new Point(topLeft.X + 1.0 / 6.0 * width, topLeft.Y + height / 2.0);

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 2, 2);

        }

        public void AddToCanvas()
        {
            var clone = Clone();
            (clone as ActivityStroke).IsDrawingDone = true;
            SurfaceDessin.Strokes.Add(clone);
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
        }
    }
    
}
