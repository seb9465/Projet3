using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using PolyPaint.Utilitaires;

namespace PolyPaint.Strokes
{
    public abstract class AbstractShapeStroke : AbstractStroke
    {
        public ConcurrentDictionary<AnchorPosition, Point> AnchorPoints { get; set; }

        public ConcurrentDictionary<AbstractLineStroke, AnchorPosition> InConnections { get; set; }
        public ConcurrentDictionary<AbstractLineStroke, AnchorPosition> OutConnections { get; set; }

        public AbstractShapeStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string title, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            AnchorPoints = new ConcurrentDictionary<AnchorPosition, Point>(
                new Dictionary<AnchorPosition, Point>()
                {
                    { AnchorPosition.Bottom, new Point() },
                    { AnchorPosition.Left, new Point() },
                    { AnchorPosition.Right, new Point() },
                    { AnchorPosition.Top, new Point() }
                }
            );

            InConnections = new ConcurrentDictionary<AbstractLineStroke, AnchorPosition>();
            OutConnections = new ConcurrentDictionary<AbstractLineStroke, AnchorPosition>();

            Title = new FormattedText(title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 17, Brushes.Black);
        }

        protected void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[AnchorPosition.Top] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y);
            AnchorPoints[AnchorPosition.Bottom] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y + UnrotatedHeight);
            AnchorPoints[AnchorPosition.Right] = new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2);
            AnchorPoints[AnchorPosition.Left] = new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + UnrotatedHeight / 2.0);
            AnchorPoints = new ConcurrentDictionary<AnchorPosition, Point>
            (
                AnchorPoints.Select(x => new KeyValuePair<AnchorPosition, Point>(x.Key, Tools.RotatePoint(x.Value, Center, Rotation)))
            );

            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Top], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Bottom], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Right], 3, 3);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Left], 3, 3);
        }
    }
}