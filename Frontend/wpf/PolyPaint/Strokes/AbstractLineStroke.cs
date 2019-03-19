using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractLineStroke : AbstractStroke
    {
        protected FormattedText Source { get; set; }
        public string SourceString
        {
            get { return Source.Text; }
            set
            {
                Source = new FormattedText(value, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
                ProprieteModifiee("Source");
                ProprieteModifiee();
            }
        }

        protected FormattedText Destination { get; set; }
        public string DestinationString
        {
            get { return Destination.Text; }
            set
            {
                Destination = new FormattedText(value, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
                ProprieteModifiee("Destination");
                ProprieteModifiee();
            }
        }

        public AbstractLineStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string from, string to, string couleurBordure, string couleurRemplissage)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage)
        {
            Source = new FormattedText(from, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
            Destination = new FormattedText(to, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
        }
    }
}
