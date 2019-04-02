using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractShapeStroke : AbstractStroke
    {
        public Point[] AnchorPoints { get; set; }

        public AbstractShapeStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string title, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            AnchorPoints = new Point[4];

            Title = new FormattedText(title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
        }
    }
}