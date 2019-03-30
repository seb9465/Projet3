using PolyPaint.Strokes;
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
using System;

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
                        DrawingStroke = new UmlClassStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "rectangle":
                        DrawingStroke = new RectangleStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "artefact":
                        DrawingStroke = new ArtefactStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "activity":
                        DrawingStroke = new ActivityStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "phase":
                        DrawingStroke = new PhaseStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "role":
                        DrawingStroke = new RoleStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "text":
                        DrawingStroke = new TextStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "asso_uni":
                        DrawingStroke = new UnidirectionalAssociationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "asso_bi":
                        DrawingStroke = new BidirectionalAssociationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "composition":
                        DrawingStroke = new CompositionStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "heritage":
                        DrawingStroke = new InheritanceStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "agregation":
                        DrawingStroke = new AgregationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "line":
                        DrawingStroke = new LineStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                }
            }
        }

        internal void EndDraw(InkCanvas surfaceDessin, DrawViewModel drawViewModel, string username)
        {
            //StylusPointCollection collection = new StylusPointCollection();

            //foreach (PolyPaintStylusPoint point in drawViewModel.StylusPoints)
            //{
            //    collection.Add(new StylusPoint()
            //    {
            //        X = point.X,
            //        Y = point.Y,
            //        PressureFactor = point.PressureFactor,
            //    });
            //}

            //Stroke stroke = null;
            //switch (drawViewModel.ItemType)
            //{
            //    case ItemTypeEnum.Comment:
            //        stroke = new RectangleStroke(collection, surfaceDessin, "#FF000000", "#FFFFFFFF");
            //        break;
            //}
            //Color color = new Color()
            //{
            //    A = drawViewModel.FillColor.A,
            //    B = drawViewModel.FillColor.B,
            //    G = drawViewModel.FillColor.G,
            //    R = drawViewModel.FillColor.R,
            //};
            //stroke.DrawingAttributes.Color = color;
            //(stroke as ICanvasable).AddToCanvas();
            StrokeBuilder builder = new StrokeBuilder();
            List<DrawViewModel> viewModel = new List<DrawViewModel>
                {
                    drawViewModel
                };
            builder.BuildStrokesFromDrawViewModels(viewModel, surfaceDessin);
            DrawingStroke = null;
        }

        internal void EndDraw(InkCanvas surfaceDessin, string outilSelectionne)
        {
            if (DrawingStroke != null)
            {
                if(DrawingStroke is AbstractLineStroke && (DrawingStroke as AbstractLineStroke).IsRelation && !(DrawingStroke as AbstractLineStroke).BothAttached)
                {
                    (DrawingStroke as ICanvasable).RemoveFromCanvas();
                }
                else
                {
                    (DrawingStroke as ICanvasable).AddToCanvas();
                }
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
            var selectedStrokes = surfaceDessin.GetSelectedStrokes();
            foreach (var stroke in selectedStrokes)
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
            foreach (Point pt in affectedAnchorPoints)
            {
                for (int i = 0; i < 2; i++)
                {
                    surfaceDessin.Strokes.Where(x => x is AbstractLineStroke &&
                        !surfaceDessin.GetSelectedStrokes().Contains(x) &&
                        Point.Subtract(x.StylusPoints[i].ToPoint(), pt).Length <= Config.MIN_DISTANCE_ANCHORS)
                        .ToList()
                        .ForEach(x => RedrawPoint(x, i, new Vector(shiftInX, shiftInY)));
                }
            }
        }

        private void RedrawPoint(Stroke stroke, int index, Vector shift)
        {
            stroke.StylusPoints[index] = new StylusPoint(stroke.StylusPoints[index].X + shift.X, stroke.StylusPoints[index].Y + shift.Y);
            (stroke as ICanvasable).AddToCanvas();
        }

        internal void ContextualMenuClick(InkCanvas surfaceDessin, string header, VueModele vm)
        {
            switch (header)
            {
                case "SelectAll":
                    surfaceDessin.Select(surfaceDessin.Strokes);
                    break;
                case "InvertSelection":
                    StrokeCollection strokesToSelect = new StrokeCollection();
                    foreach (var stroke in surfaceDessin.Strokes)
                    {
                        if (!surfaceDessin.GetSelectedStrokes().Contains(stroke))
                            strokesToSelect.Add(stroke);
                    }
                    surfaceDessin.Select(strokesToSelect);
                    break;
                case "InvertColors":
                    InvertStrokesColors(surfaceDessin);
                    break;
                case "TransformAllShapes":
                    TransformAllShapes(surfaceDessin, vm);
                    break;
                case "TransformAllConnections":
                    TransformAllConnections(surfaceDessin, vm);
                    break;
                case "TransformAllShapesAndConnections":
                    TransformAllShapes(surfaceDessin, vm);
                    TransformAllConnections(surfaceDessin, vm);
                    break;
            }
        }

        private void InvertStrokesColors(InkCanvas surfaceDessin)
        {
            foreach (AbstractShapeStroke stroke in surfaceDessin.GetSelectedStrokes().Where(x => x is AbstractShapeStroke))
            {
                stroke.SetBorderColor(InvertColorValue(stroke.BorderColor).ToString());
                stroke.SetFillColor(InvertColorValue(stroke.FillColor).ToString());
            }
            foreach (AbstractLineStroke stroke in surfaceDessin.GetSelectedStrokes().Where(x => x is AbstractLineStroke))
            {
                stroke.SetBorderColor(InvertColorValue(stroke.BorderColor).ToString());
                stroke.SetFillColor(InvertColorValue(stroke.FillColor).ToString());
            }
        }

        private Color InvertColorValue(Color color)
        {
            return Color.FromArgb(color.A, (byte)~color.R, (byte)~color.G, (byte)~color.B);
        }

        private void TransformAllShapes(InkCanvas surfaceDessin, VueModele vm)
        {
            foreach (AbstractShapeStroke stroke in surfaceDessin.Strokes.Where(x => x is AbstractShapeStroke))
            {
                stroke.SetBorderColor(vm.CouleurSelectionneeBordure);
                stroke.SetFillColor(vm.CouleurSelectionneeRemplissage);
                //stroke.SetBorderStyle(Tools.DashAssociations[vm.SelectedBorder]);
            }
        }
        private void TransformAllConnections(InkCanvas surfaceDessin, VueModele vm)
        {
            foreach (AbstractLineStroke stroke in surfaceDessin.Strokes.Where(x => x is AbstractLineStroke))
            {
                stroke.SetBorderColor(vm.CouleurSelectionneeBordure);
                stroke.SetFillColor(vm.CouleurSelectionneeRemplissage);
                //stroke.SetBorderStyle(Tools.DashAssociations[vm.SelectedBorder]);
            }
        }
    }
}
