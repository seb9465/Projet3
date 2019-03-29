using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractShapeStroke : AbstractStroke
    {
        public Point[] AnchorPoints { get; set; }

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

        public AbstractShapeStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string title, string couleurBordure, string couleurRemplissage, double thicc)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc)
        {
            AnchorPoints = new Point[4];

            Title = new FormattedText(title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
        }
    }
}