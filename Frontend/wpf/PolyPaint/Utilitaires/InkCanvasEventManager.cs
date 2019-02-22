using PolyPaint.Common;
using PolyPaint.Strokes;
using PolyPaint.VueModeles;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Utilitaires
{
    internal class InkCanvasEventManager
    {
        public Stroke DrawingStroke = null;

        public void SelectItem(InkCanvas surfaceDessin, Point mouseLeftDownPoint)
        {
            InkCanvasEditingMode all = surfaceDessin.EditingMode;
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
                surfaceDessin.Strokes.Remove(DrawingStroke);

            switch (outilSelectionne)
            {
                case "rectangle":
                    DrawingStroke = new RectangleStroke(pts);
                    DrawingStroke.DrawingAttributes.Color = Colors.LightBlue;
                    surfaceDessin.Strokes.Add(DrawingStroke);
                    break;
                case "rounded_rectangle":
                    DrawingStroke = new RoundedRectangleStroke(pts);
                    DrawingStroke.DrawingAttributes.Color = Colors.Red;
                    surfaceDessin.Strokes.Add(DrawingStroke);
                    break;
            }
        }

        internal void EndDraw(InkCanvas surfaceDessin, string outilSelectionne, DrawViewModel drawViewModel)
        {
            if (DrawingStroke != null && outilSelectionne == "rectangle"
                                      || outilSelectionne == "rounded_rectangle")
            {


                StylusPointCollection collection = new StylusPointCollection();

                foreach (PolyPaintStylusPoint point in drawViewModel.StylusPoints)
                {
                    collection.Add(new StylusPoint()
                    {
                        X = point.X,
                        Y = point.Y,
                        PressureFactor = point.PressureFactor,
                    });
                }

                Stroke stroke = null;
                switch (drawViewModel.ItemType)
                {
                    case ItemTypeEnum.RoundedRectangleStroke:
                        stroke = new RoundedRectangleStroke(collection);
                        break;
                }
                Color color = new Color()
                {
                    A = drawViewModel.Color.A,
                    B = drawViewModel.Color.B,
                    G = drawViewModel.Color.G,
                    R = drawViewModel.Color.R,
                };
                stroke.DrawingAttributes.Color = color;
                surfaceDessin.Strokes.Remove(stroke);
                surfaceDessin.Strokes.Add(stroke.Clone());
            }
        }
    }
}
