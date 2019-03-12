using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractStroke : Stroke
    {
        public Point[] AnchorPoints { get; set; }
        public bool IsDrawingDone { get; set; }

        protected Point TopLeft { get; set; }
        protected double Width { get; set; }
        protected double Height { get; set; }

        protected Brush Fill { get; set; }
        protected Pen Border { get; set; }
        
        protected InkCanvas SurfaceDessin { get; set; }
        protected FormattedText Title { get; set; }

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
    }
}