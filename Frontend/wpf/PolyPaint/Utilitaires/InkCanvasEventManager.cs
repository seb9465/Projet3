using PolyPaint.Strokes;
using PolyPaint.Vues;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Utilitaires
{
    class InkCanvasEventManager
    {
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

        public void ChangeText(InkCanvas surfaceDessin, Point mouseLeftDownPoint)
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
                    if (strokes[i] is UmlClassStroke)
                    {
                        var editWindow = new EditUmlWindow(strokes[i] as UmlClassStroke, surfaceDessin);
                        editWindow.Show();
                    }
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
                case "uml_class":
                    DrawingStroke = new UmlClassStroke(pts, surfaceDessin);
                    DrawingStroke.DrawingAttributes.Color = Colors.LightBlue;
                    surfaceDessin.Strokes.Add(DrawingStroke);
                    break;
                case "rectangle":
                    DrawingStroke = new RectangleStroke(pts, surfaceDessin);
                    DrawingStroke.DrawingAttributes.Color = Colors.LightBlue;
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
            if (DrawingStroke != null && outilSelectionne == "uml_class"
                                      || outilSelectionne == "rectangle")
            {
                (DrawingStroke as ICanvasable).RemoveFromCanvas();
                (DrawingStroke as ICanvasable).AddToCanvas();
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
                AbstractStroke[] strokes = ToAbstractStrokes(surfaceDessin.Strokes);
                List<Point> anchors = GetAllAnchorPoints(strokes);
                for (int i = 0; i < anchors.Count; ++i)
                {
                    double d1 = Point.Subtract(anchors[i], firstPoint).Length;
                    double d2 = Point.Subtract(anchors[i], secondPoint).Length;
                    if (d1 < distanceToFirst)
                    {
                        closestToFirst = anchors[i];
                        distanceToFirst = d1;
                    }
                    if (d2 < distanceToSecond)
                    {
                        closestToSecond = anchors[i];
                        distanceToSecond = d2;

                    }
                }
                StylusPointCollection points = new StylusPointCollection(new Point[] { closestToFirst, closestToSecond });
                DrawingStroke = new LineStroke(points, surfaceDessin);
                DrawingStroke.DrawingAttributes.Color = Colors.Black;
                surfaceDessin.Strokes.Add(DrawingStroke);
                (DrawingStroke as ICanvasable).AddToCanvas();
            }
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
         }

        private void RedrawLineOnAffectedAnchorPoints(InkCanvas surfaceDessin, List<Point> affectedAnchorPoints, 
                                                      double shiftInX, double shiftInY)
        {
            for (int i = 0; i < surfaceDessin.Strokes.Count(); ++i)
            {
                if (surfaceDessin.Strokes[i].GetType() == typeof(LineStroke))
                {
                    if (!surfaceDessin.GetSelectedStrokes().Contains(surfaceDessin.Strokes[i]))
                    {
                        StylusPointCollection points = surfaceDessin.Strokes[i].StylusPoints;
                        if (affectedAnchorPoints.Contains(surfaceDessin.Strokes[i].StylusPoints[0].ToPoint()))
                        {
                            points[0] = new StylusPoint(points[0].X + shiftInX, points[0].Y + shiftInY);

                            DrawingStroke = new LineStroke(points, surfaceDessin);
                            DrawingStroke.DrawingAttributes.Color = Colors.Black;
                            surfaceDessin.Strokes.Add(DrawingStroke);
                            (surfaceDessin.Strokes[i] as ICanvasable).RemoveFromCanvas();
                            (DrawingStroke as ICanvasable).AddToCanvas();
                            i--;

                        }
                        else if (affectedAnchorPoints.Contains(surfaceDessin.Strokes[i].StylusPoints[1].ToPoint()))
                        {
                            points[1] = new StylusPoint(points[1].X + shiftInX, points[1].Y + shiftInY);

                            DrawingStroke = new LineStroke(points, surfaceDessin);
                            DrawingStroke.DrawingAttributes.Color = Colors.Black;
                            surfaceDessin.Strokes.Add(DrawingStroke);
                            (surfaceDessin.Strokes[i] as ICanvasable).RemoveFromCanvas();
                            (DrawingStroke as ICanvasable).AddToCanvas();
                            i--;
                        }
                    }
                }
            }
        }

        private AbstractStroke[] ToAbstractStrokes(StrokeCollection strokeCollection)
        {
            AbstractStroke[] strokes = new AbstractStroke[strokeCollection.Count];
            for(int i = 0; i < strokeCollection.Count; ++i)
            {
                if (!(strokeCollection[i].GetType() == typeof(LineStroke)))
                    strokes[i] = (AbstractStroke)strokeCollection[i];
            }
            return strokes;
        }

        private List<Point> GetAllAnchorPoints(AbstractStroke[] strokes)
        {
            List<Point> anchors = new List<Point>();
            for (int i = 0; i < strokes.Count(); ++i)
            {
                if (strokes[i] == null)
                    break;

                for (int j = 0; j < 4; ++j)
                {
                    anchors.Add(strokes[i].AnchorPoints[j]);
                }
            }
            return anchors;
        }
    }
}
