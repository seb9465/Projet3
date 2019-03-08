using PolyPaint.Strokes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Utilitaires
{
    class InkCanvasEventManager
    {
        List<Point> AnchorPoints = new List<Point>();
        Stroke DrawingStroke = null;

        public void SelectItem(InkCanvas surfaceDessin, Point mouseLeftDownPoint)
        {
            StrokeCollection strokes = surfaceDessin.Strokes;

            // We travel the StrokeCollection inversely to select the first plan item first
            // if some items overlap.
            StrokeCollection strokeToSelect = new StrokeCollection();
            for (int i = strokes.Count - 1; i >= 0; i--)
            {
                Rect box = strokes[i].GetBounds();
                if (mouseLeftDownPoint.X >= box.Left && mouseLeftDownPoint.X <= box.Right &&
                    mouseLeftDownPoint.Y <= box.Bottom && mouseLeftDownPoint.Y >= box.Top)
                {
                    strokeToSelect.Add(strokes[i]);
                    surfaceDessin.Select(strokeToSelect);
                    break;
                }
            }
        }

        public void DrawShape(InkCanvas surfaceDessin, string outilSelectionne, Point currentPoint, Point mouseLeftDownPoint)
        {
            StylusPointCollection pts = new StylusPointCollection();

            pts.Add(new StylusPoint(mouseLeftDownPoint.X, mouseLeftDownPoint.Y));
            pts.Add(new StylusPoint(currentPoint.X, currentPoint.Y));

            if (DrawingStroke != null)
            {
                (DrawingStroke as ICanvasable).RemoveFromCanvas();
            }

            switch (outilSelectionne)
            {
                case "rectangle":
                    DrawingStroke = new RectangleStroke(pts, "Titre", surfaceDessin);
                    DrawingStroke.DrawingAttributes.Color = Colors.LightBlue;
                    surfaceDessin.Strokes.Add(DrawingStroke);
                    break;
                case "rounded_rectangle":
                    DrawingStroke = new RoundedRectangleStroke(pts);
                    DrawingStroke.DrawingAttributes.Color = Colors.Red;
                    surfaceDessin.Strokes.Add(DrawingStroke);
                    break;
                case "line":
                    DrawingStroke = new LineStroke(pts, surfaceDessin);
                    DrawingStroke.DrawingAttributes.Color = Colors.Black;
                    surfaceDessin.Strokes.Add(DrawingStroke);
                    break;
            }
        }

        internal void EndDraw(InkCanvas surfaceDessin, string outilSelectionne)
        {
            if (DrawingStroke != null && outilSelectionne == "rectangle"
                                      || outilSelectionne == "rounded_rectangle")
            {
                (DrawingStroke as ICanvasable).RemoveFromCanvas();
                (DrawingStroke as ICanvasable).AddToCanvas();
                AddAnchorPointsToList(DrawingStroke.StylusPoints);
            }
            else if (DrawingStroke != null && outilSelectionne == "line")
            {

            }
        }

        private void AddAnchorPointsToList(StylusPointCollection stylusPoints)
        {
            Point topLeft = new Point(stylusPoints[0].X, stylusPoints[0].Y);
            double width = (stylusPoints[1].X - stylusPoints[0].X);
            double height = (stylusPoints[1].Y - stylusPoints[0].Y);

            AnchorPoints.Add(new Point(topLeft.X + width / 2, topLeft.Y));
            AnchorPoints.Add(new Point(topLeft.X + width / 2, topLeft.Y + height));
            AnchorPoints.Add(new Point(topLeft.X + width, topLeft.Y + height / 2));
            AnchorPoints.Add(new Point(topLeft.X, topLeft.Y + height / 2));
        }
    }
}
