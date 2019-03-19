using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractShapeStroke : AbstractStroke
    {
        public Point[] AnchorPoints { get; set; }

        protected Point TopLeft { get; set; }
        protected double Width { get; set; }
        protected double Height { get; set; }

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

        public AbstractShapeStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string title, string couleurBordure, string couleurRemplissage)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage)
        {
            TopLeft = new Point();
            Width = 0;
            Height = 0;

            AnchorPoints = new Point[4];

            Title = new FormattedText(title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
        }
    }
}