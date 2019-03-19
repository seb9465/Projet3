using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System;

namespace PolyPaint.Strokes
{
    public abstract class AbstractStroke : Stroke, ICanvasable, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public Point[] AnchorPoints { get; set; }
        public bool IsDrawingDone { get; set; }

        protected Point TopLeft { get; set; }
        protected double Width { get; set; }
        protected double Height { get; set; }

        protected Brush Fill { get; set; }
        protected Pen Border { get; set; }
        public DashStyle BorderStyle { get { return Border.DashStyle; } }
        public Color BorderColor { get { return (Border.Brush as SolidColorBrush).Color;  } }
        public Color FillColor { get { return (Fill as SolidColorBrush).Color; } }

        protected InkCanvas SurfaceDessin { get; set; }
        protected FormattedText Title { get; set; }
        public string TitleString
        {
            get { return Title.Text; }
            set
            {
                Title = new FormattedText(value, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
                ProprieteModifiee("Title");
                ProprieteModifiee();
            }
        }

        public AbstractStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string title, string couleurBordure, string couleurRemplissage) : base(stylusPoints)
        {
            TopLeft = new Point();
            Width = 0;
            Height = 0;

            couleurRemplissage = couleurRemplissage == "" ? "#FFFFFFFF" : couleurRemplissage;
            couleurBordure = couleurBordure == "" ? "#FF000000" : couleurBordure;

            Fill = new SolidColorBrush((Color)ColorConverter.ConvertFromString(couleurRemplissage));
            Border = new Pen(new SolidColorBrush((Color)ColorConverter.ConvertFromString(couleurBordure)), 2);

            AnchorPoints = new Point[4];
            IsDrawingDone = false;

            SurfaceDessin = surfaceDessin;
            Title = new FormattedText(title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public void AddToCanvas()
        {
            RemoveFromCanvas();
            var clone = Clone();
            (clone as AbstractStroke).IsDrawingDone = true;
            SurfaceDessin.Strokes.Add(clone);
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
        }

        public void SetBorderStyle(DashStyle style)
        {
            Border.DashStyle = style;
            Redraw();
        }

        public void SetBorderThickness(double thickness)
        {
            Border.Thickness = thickness;
            Redraw();
        }

        public void SetBorderColor(string color)
        {
            var dashStyle = Border.DashStyle;
            Border = new Pen(new SolidColorBrush((Color)ColorConverter.ConvertFromString(color)), Border.Thickness);
            Border.DashStyle = dashStyle;
            Redraw();
        }

        public void SetFillColor(string color)
        {
            Fill = new SolidColorBrush((Color)ColorConverter.ConvertFromString(color));
            Redraw();
        }

        public void Redraw()
        {
            OnInvalidated(new EventArgs());
        }
    }
}