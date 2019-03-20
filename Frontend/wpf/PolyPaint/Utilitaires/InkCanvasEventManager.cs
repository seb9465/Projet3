﻿using PolyPaint.Strokes;
using PolyPaint.Common.Collaboration;
using PolyPaint.Vues;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using PolyPaint.VueModeles;

namespace PolyPaint.Utilitaires
{
    class InkCanvasEventManager
    {
        public Stroke DrawingStroke = null;

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
                    else if (strokes[i] is AbstractShapeStroke)
                    {
                        var editWindow = new EditTitleWindow(strokes[i] as AbstractShapeStroke, surfaceDessin);
                        editWindow.Show();
                    }
                    break;
                }
            }
        }

        public void DrawShape(InkCanvas surfaceDessin, VueModele vm, Point currentPoint, Point mouseLeftDownPoint)
        {
            StylusPointCollection pts = new StylusPointCollection();

            pts.Add(new StylusPoint(mouseLeftDownPoint.X, mouseLeftDownPoint.Y));
            pts.Add(new StylusPoint(currentPoint.X, currentPoint.Y));

            if (DrawingStroke != null)
            {
                (DrawingStroke as AbstractStroke).StylusPoints = pts;
            }
            else
            {
                switch (vm.OutilSelectionne)
                {
                    case "uml_class":
                        DrawingStroke = new UmlClassStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "rectangle":
                        DrawingStroke = new RectangleStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "artefact":
                        DrawingStroke = new ArtefactStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "activity":
                        DrawingStroke = new ActivityStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "phase":
                        DrawingStroke = new PhaseStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "role":
                        DrawingStroke = new RoleStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "text":
                        DrawingStroke = new TextStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "asso_uni":
                        DrawingStroke = new UnidirectionalAssociationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "asso_bi":
                        DrawingStroke = new BidirectionalAssociationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "composition":
                        DrawingStroke = new CompositionStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "heritage":
                        DrawingStroke = new InheritanceStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "agregation":
                        DrawingStroke = new AgregationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                }
            }
        }

        internal void EndDraw(InkCanvas surfaceDessin, DrawViewModel drawViewModel, string username)
        {
            if (DrawingStroke != null && (drawViewModel.OutilSelectionne == "rectangle"
                                      || drawViewModel.OutilSelectionne == "uml_class"
                                      || drawViewModel.OutilSelectionne == "activity"
                                      || drawViewModel.OutilSelectionne == "artefact"
                                      || drawViewModel.OutilSelectionne == "phase"
                                      || drawViewModel.OutilSelectionne == "role"
                                      || drawViewModel.OutilSelectionne == "text"))
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
                    case ItemTypeEnum.RectangleStroke:
                        stroke = new RectangleStroke(collection, surfaceDessin, "#FF000000", "#FFFFFFFF");
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
                (stroke as ICanvasable).AddToCanvas();
            }
        }

        internal void EndDraw(InkCanvas surfaceDessin, string outilSelectionne)
        {
            if (DrawingStroke != null)
            {
                (DrawingStroke as ICanvasable).AddToCanvas();
                DrawingStroke = null;
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
            for (int i = 0; i < 2; i++)
            {
                surfaceDessin.Strokes.Where(x => (x is UnidirectionalAssociationStroke
                                               || x is BidirectionalAssociationStroke
                                               || x is AgregationStroke
                                               || x is CompositionStroke
                                               || x is InheritanceStroke) &&
                    !surfaceDessin.GetSelectedStrokes().Contains(x) &&
                    affectedAnchorPoints.Contains(x.StylusPoints[i].ToPoint()))
                    .ToList()
                    .ForEach(x => RedrawPoint(x, i, new Vector(shiftInX, shiftInY)));
            }
        }

        private void RedrawPoint(Stroke stroke, int index, Vector shift)
        {
            stroke.StylusPoints[index] = new StylusPoint(stroke.StylusPoints[index].X + shift.X, stroke.StylusPoints[index].Y + shift.Y);
            (stroke as ICanvasable).AddToCanvas();
        }
    }
}
