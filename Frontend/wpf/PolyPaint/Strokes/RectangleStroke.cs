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
    public class RectangleStroke : AbstractStroke, ICanvasable, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        public string Title { get; set; }
        public ObservableCollection<Property> Properties { get; set; }
        public ObservableCollection<Method> Methods { get; set; }

        public InkCanvas SurfaceDessin { get; set; }
        public bool IsDrawingDone = false;

        public RelayCommand<string> AddProperty { get; set; }
        public RelayCommand<string> AddMethod { get; set; }
        public RelayCommand<string> RemoveFromProperties { get; set; }
        public RelayCommand<string> RemoveFromMethods { get; set; }

        public RectangleStroke(StylusPointCollection pts, InkCanvas surfaceDessin)
            : base(pts)
        {
            StylusPoints = pts;
            Title = "Class";
            Properties = new ObservableCollection<Property>();
            Methods = new ObservableCollection<Method>();

            SurfaceDessin = surfaceDessin;
            AnchorPoints = new Point[4];

            AddProperty = new RelayCommand<string>(addProperty);
            AddMethod = new RelayCommand<string>(addMethod);
            RemoveFromProperties = new RelayCommand<string>(removeFromProperties);
            RemoveFromMethods = new RelayCommand<string>(removeFromMethods);
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
            SolidColorBrush brush = new SolidColorBrush(drawingAttributes.Color);
            brush.Freeze();
            StylusPoint stp = StylusPoints[0];
            StylusPoint sp = StylusPoints[1];

            drawingContext.DrawRectangle(brush, null, new Rect(new Point(sp.X, sp.Y), new Point(stp.X, stp.Y)));
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
            AnchorPoints[3] = new Point(topLeft.X, topLeft.Y + height / 2);

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 2, 2);

        }

        public void AddToCanvas()
        {
            var clone = Clone();
            (clone as RectangleStroke).IsDrawingDone = true;
            SurfaceDessin.Strokes.Add(clone);
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
        }

        private void addProperty(string bidon)
        {
            Properties.Add(new Property("NewProperty"));
            ProprieteModifiee("Properties");
        }

        private void addMethod(string bidon)
        {
            Methods.Add(new Method("NewMethod"));
            ProprieteModifiee("Methods");
        }

        private void removeFromProperties(string prop)
        {
            Properties.Remove(Properties.FirstOrDefault(x => x.Title == prop));
            ProprieteModifiee("Properties");
        }

        private void removeFromMethods(string method)
        {
            Methods.Remove(Methods.FirstOrDefault(x => x.Title == method));
            ProprieteModifiee("Methods");
        }
    }
    
}
