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
    public class UmlClassStroke : AbstractShapeStroke
    {
        public ObservableCollection<Property> Properties { get; set; }
        public ObservableCollection<Method> Methods { get; set; }

        public RelayCommand<string> AddProperty { get; set; }
        public RelayCommand<string> AddMethod { get; set; }
        public RelayCommand<string> RemoveFromProperties { get; set; }
        public RelayCommand<string> RemoveFromMethods { get; set; }

        public UmlClassStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(pts, surfaceDessin, "Class", couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            Properties = new ObservableCollection<Property>();
            Methods = new ObservableCollection<Method>();

            AddProperty = new RelayCommand<string>(addProperty);
            AddMethod = new RelayCommand<string>(addMethod);
            RemoveFromProperties = new RelayCommand<string>(removeFromProperties);
            RemoveFromMethods = new RelayCommand<string>(removeFromMethods);
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


            PointCollection points = new PointCollection();
            points.Add(UnrotatedTopLeft);
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight));
            points = new PointCollection(points.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)));

            drawingContext.DrawRectangle(Fill, Border, new Rect(points[0], points[1]));
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
            var nextHeight = UnrotatedTopLeft.Y + 10;

            drawingContext.DrawText(Title, new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0 - Title.Width / 2.0, nextHeight));
            nextHeight += 10 + Title.Height;
            drawingContext.DrawLine(Border, new Point(UnrotatedTopLeft.X, nextHeight), new Point(UnrotatedTopLeft.X + UnrotatedWidth, nextHeight));
            nextHeight += 10;
            for (int i = 0; i < Properties.Count; i++)
            {
                var tempFt = new FormattedText($"• {Properties[i].Title}", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, new SolidColorBrush(Colors.Black));
                drawingContext.DrawText(tempFt, new Point(UnrotatedTopLeft.X + 10, nextHeight));
                nextHeight += 10 + tempFt.Height;
            }
            drawingContext.DrawLine(Border, new Point(UnrotatedTopLeft.X, nextHeight), new Point(UnrotatedTopLeft.X + UnrotatedWidth, nextHeight));
            nextHeight += 10;
            for (int i = 0; i < Methods.Count; i++)
            {
                var tempFt = new FormattedText($"• {Methods[i].Title}", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, new SolidColorBrush(Colors.Black));
                drawingContext.DrawText(tempFt, new Point(UnrotatedTopLeft.X + 10, nextHeight));
                nextHeight += 10 + tempFt.Height;
            }
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[0] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y);
            AnchorPoints[1] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y + UnrotatedHeight);
            AnchorPoints[2] = new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2);
            AnchorPoints[3] = new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + UnrotatedHeight / 2);
            AnchorPoints = AnchorPoints.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)).ToArray();

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 3, 3);
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

    public class Property : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        private string _title { get; set; }
        public string Title
        {
            get { return _title; }
            set { _title = value; ProprieteModifiee(); }
        }

        public Property(string title)
        {
            Title = title;
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class Method : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        private string _title { get; set; }
        public string Title
        {
            get { return _title; }
            set { _title = value; ProprieteModifiee(); }
        }

        public Method(string title)
        {
            Title = title;
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
