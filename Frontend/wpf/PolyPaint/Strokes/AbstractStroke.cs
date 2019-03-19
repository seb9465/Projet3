using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractStroke : Stroke, ICanvasable, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public bool IsDrawingDone { get; set; }

        protected Brush Fill { get; set; }
        protected Pen Border { get; set; }
        public DashStyle BorderStyle { get { return Border.DashStyle; } }
        public Color BorderColor { get { return (Border.Brush as SolidColorBrush).Color; } }
        public Color FillColor { get { return (Fill as SolidColorBrush).Color; } }

        protected InkCanvas SurfaceDessin { get; set; }

        public AbstractStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage)
            : base(pts)
        {
            couleurBordure = couleurBordure == "" ? "#FF000000" : couleurBordure;
            couleurRemplissage = couleurRemplissage == "" ? "#FFFFFFFF" : couleurRemplissage;

            Border = new Pen(new SolidColorBrush((Color)ColorConverter.ConvertFromString(couleurBordure)), 2);
            Fill = new SolidColorBrush((Color)ColorConverter.ConvertFromString(couleurRemplissage));

            IsDrawingDone = false;

            SurfaceDessin = surfaceDessin;
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
