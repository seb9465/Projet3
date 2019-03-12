﻿using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;
using System.ComponentModel;
using System.Runtime.CompilerServices;

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

        public AbstractStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string title) : base(stylusPoints)
        {
            TopLeft = new Point();
            Width = 0;
            Height = 0;

            Fill = Brushes.LightGray;
            Border = new Pen(Brushes.Black, 2);

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