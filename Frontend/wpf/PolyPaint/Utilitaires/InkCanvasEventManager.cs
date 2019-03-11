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

                (DrawingStroke as ICanvasable).RemoveFromCanvas();
                Point closestToFirst = new Point();
                Point closestToSecond = new Point();
                Point firstPoint = new Point(DrawingStroke.StylusPoints[0].X, DrawingStroke.StylusPoints[0].Y);
                Point secondPoint = new Point(DrawingStroke.StylusPoints[1].X, DrawingStroke.StylusPoints[1].Y);
                double distanceToFirst = 1000;
                double distanceToSecond = 1000;
                for (int i = 0; i < AnchorPoints.Count(); i++)
                {
                    double d1 = Point.Subtract(AnchorPoints[i], firstPoint).Length;
                    double d2 = Point.Subtract(AnchorPoints[i], secondPoint).Length;
                    if (d1 < distanceToFirst)
                    {
                        closestToFirst = AnchorPoints[i];
                        distanceToFirst = d1;
                    }
                    if (d2 < distanceToSecond)
                    {
                        closestToSecond = AnchorPoints[i];
                        distanceToSecond = d2;

                    }
                }
                StylusPointCollection points = new StylusPointCollection(new Point[] {closestToFirst, closestToSecond});
                DrawingStroke = new LineStroke(points, surfaceDessin);
                DrawingStroke.DrawingAttributes.Color = Colors.Black;
                surfaceDessin.Strokes.Add(DrawingStroke);
                (DrawingStroke as ICanvasable).AddToCanvas();
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
        public void RedrawConnections(InkCanvas surfaceDessin, string outilSelectionne, Rect oldRectangle, Rect newRectangle)
        {
            UpdateAnchorPointsPosition(surfaceDessin, oldRectangle, newRectangle);
        }

        private void UpdateAnchorPointsPosition(InkCanvas surfaceDessin, Rect oldRectangle, Rect newRectangle)
        {
            double shiftInX = newRectangle.Left - oldRectangle.Left;
            double shiftInY = newRectangle.Top - oldRectangle.Top;
            List<Point> affectedAnchorPoints = new List<Point>();
            var selectedStroke = surfaceDessin.GetSelectedStrokes();
            foreach (var stroke in selectedStroke)
            {
                Point topLeft = new Point(stroke.StylusPoints[0].X, stroke.StylusPoints[0].Y);
                double width = (stroke.StylusPoints[1].X - stroke.StylusPoints[0].X);
                double height = (stroke.StylusPoints[1].Y - stroke.StylusPoints[0].Y);

                affectedAnchorPoints.Add(new Point(topLeft.X + width / 2, topLeft.Y));
                affectedAnchorPoints.Add(new Point(topLeft.X + width / 2, topLeft.Y + height));
                affectedAnchorPoints.Add(new Point(topLeft.X + width, topLeft.Y + height / 2));
                affectedAnchorPoints.Add(new Point(topLeft.X, topLeft.Y + height / 2));
            }

            RedrawLineOnAffectedAnchorPoints(surfaceDessin, affectedAnchorPoints, shiftInX, shiftInY);

            foreach (var point in affectedAnchorPoints)
            {
                for (int i = 0; i < AnchorPoints.Count(); ++i)
                {
                    if (point == AnchorPoints[i])
                    {
                        AnchorPoints[i] = new Point(point.X + shiftInX, point.Y + shiftInY);
                    }
                }
            }
         }

        private void RedrawLineOnAffectedAnchorPoints(InkCanvas surfaceDessin, List<Point> affectedAnchorPoints, 
                                                      double shiftInX, double shiftInY)
        {
            for (int i = 0; i < surfaceDessin.Strokes.Count(); ++i)
            {
                if (surfaceDessin.Strokes[i].GetType() == typeof(LineStroke))
                {
                    if (affectedAnchorPoints.Contains(surfaceDessin.Strokes[i].StylusPoints[0].ToPoint()))
                    {
                        //DrawingStroke = new LineStroke(pts, surfaceDessin);
                        //DrawingStroke.DrawingAttributes.Color = Colors.Black;
                        //surfaceDessin.Strokes.Add(DrawingStroke);

                    }
                    if (affectedAnchorPoints.Contains(surfaceDessin.Strokes[i].StylusPoints[1].ToPoint()))
                    {

                    }
                    surfaceDessin.Strokes.Remove(surfaceDessin.Strokes[i]);
                }
            }
        }
    }
}
