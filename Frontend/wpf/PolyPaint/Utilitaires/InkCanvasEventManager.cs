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

namespace PolyPaint.Utilitaires
{
    class InkCanvasEventManager
    {
        public Stroke DrawingStroke = null;

        public Window ChangeText(InkCanvas surfaceDessin, Point mouseLeftDownPoint, VueModele vm)
        {
            StrokeCollection strokes = surfaceDessin.Strokes;
            Window window = new Window();

            // We travel the StrokeCollection inversely to select the first plan item first
            // if some items overlap.
            StrokeCollection strokeToSelect = new StrokeCollection();
            PhaseStroke potentialPhase = null;
            for (int i = strokes.Count - 1; i >= 0; i--)
            {
                Rect box = strokes[i].GetBounds();
                if (mouseLeftDownPoint.X >= box.Left && mouseLeftDownPoint.X <= box.Right &&
                    mouseLeftDownPoint.Y <= box.Bottom && mouseLeftDownPoint.Y >= box.Top &&
                    !vm.GetOnlineSelection().Values.Any(x => x.Any(y => y.Guid == ((AbstractStroke)strokes[i]).Guid.ToString())))
                {
                    if (strokes[i] is PhaseStroke)
                    {
                        potentialPhase = (PhaseStroke)strokes[i];
                        continue;
                    }
                    if (strokes[i] is UmlClassStroke)
                    {
                        strokeToSelect.Add(strokes[i]);
                        window = new EditUmlWindow(strokes[i] as UmlClassStroke, surfaceDessin, vm);
                        window.Show();
                    }
                    else if (strokes[i] is AbstractShapeStroke)
                    {
                        strokeToSelect.Add(strokes[i]);
                        window = new EditTitleWindow(strokes[i] as AbstractShapeStroke, surfaceDessin, vm);
                        window.Show();
                    }
                    else if (strokes[i] is AbstractLineStroke)
                    {
                        strokeToSelect.Add(strokes[i]);
                        window = new EditLineTitleWindow(strokes[i] as AbstractLineStroke, surfaceDessin, vm);
                        window.Show();
                    }
                    break;
                }
            }
            if (strokeToSelect.Count == 0 && potentialPhase != null)
            {
                strokeToSelect.Add(potentialPhase);
                window = new EditTitleWindow(potentialPhase, surfaceDessin, vm);
                window.Show();
            }
            return window;
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
                        DrawingStroke = new UmlClassStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "rectangle":
                        DrawingStroke = new RectangleStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "artefact":
                        DrawingStroke = new ArtefactStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "activity":
                        DrawingStroke = new ActivityStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "phase":
                        DrawingStroke = new PhaseStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "role":
                        DrawingStroke = new RoleStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "text":
                        DrawingStroke = new TextStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.CouleurSelectionneeRemplissage, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "asso_uni":
                        DrawingStroke = new UnidirectionalAssociationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "asso_bi":
                        DrawingStroke = new BidirectionalAssociationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "composition":
                        DrawingStroke = new CompositionStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "heritage":
                        DrawingStroke = new InheritanceStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "agregation":
                        DrawingStroke = new AgregationStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "line":
                        DrawingStroke = new LineStroke(pts, surfaceDessin, vm.CouleurSelectionneeBordure, vm.TailleTrait, vm.SelectedBorderDashStyle);
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                }
            }
        }

        internal void EndDrawAsync(InkCanvas surfaceDessin, VueModele vm)
        {
            if (DrawingStroke != null)
            {
                if (DrawingStroke is AbstractLineStroke && (DrawingStroke as AbstractLineStroke).IsRelation && !(DrawingStroke as AbstractLineStroke).BothAttached)
                {
                    (DrawingStroke as ICanvasable).RemoveFromCanvas();
                }
                else
                {
                    var hihi = new StrokeCollection() { DrawingStroke };
                    if (DrawingStroke is AbstractLineStroke)
                    {
                        var elbow = (DrawingStroke as AbstractLineStroke).LastElbowPosition;
                        var sPoints = (DrawingStroke as AbstractLineStroke).StylusPoints;
                        (DrawingStroke as AbstractLineStroke).StylusPoints = new StylusPointCollection(3) { sPoints[0], sPoints[1], new StylusPoint(elbow.X, elbow.Y) };
                        hihi.Add((DrawingStroke as AbstractLineStroke).TrySnap());
                    }
                    (DrawingStroke as ICanvasable).AddToCanvas();

                    List<DrawViewModel> allo = StrokeBuilder.GetDrawViewModelsFromStrokes(hihi);
                    vm.SelectItem(((AbstractStroke)DrawingStroke).Center);
                    vm.CollaborationClient.CollaborativeDrawAsync(allo);
                    vm.CollaborationClient.CollaborativeSelectAsync(StrokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection() { DrawingStroke }));
                }
                DrawingStroke = null;
            }
        }

        public static StrokeCollection UpdateAnchorPointsPositionFor(StrokeCollection strokes, InkCanvas surfaceDessin)
        {
            var selectedStrokes = strokes;
            var shapes = selectedStrokes.Where(x => x is AbstractShapeStroke);
            var affectedStrokes = new StrokeCollection();

            foreach (AbstractShapeStroke shape in shapes)
            {
                foreach (var conn in shape.InConnections)
                {
                    var newAnchorPoint = shape.AnchorPoints[conn.Value];
                    var lineStroke = surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid == conn.Key);
                    if (lineStroke != null)
                    {
                        lineStroke.StylusPoints[1] = new StylusPoint(newAnchorPoint.X, newAnchorPoint.Y);
                        if (!affectedStrokes.Select(x => (x as AbstractStroke).Guid).Contains((lineStroke as AbstractStroke).Guid)) affectedStrokes.Add(lineStroke);
                    }
                }
                foreach (var conn in shape.OutConnections)
                {
                    var newAnchorPoint = shape.AnchorPoints[conn.Value];
                    var lineStroke = surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid == conn.Key);
                    if (lineStroke != null)
                    {
                        lineStroke.StylusPoints[0] = new StylusPoint(newAnchorPoint.X, newAnchorPoint.Y);
                        if (!affectedStrokes.Select(x => (x as AbstractStroke).Guid).Contains((lineStroke as AbstractStroke).Guid)) affectedStrokes.Add(lineStroke);
                    }
                }
            }

            return affectedStrokes;
        }

        public static StrokeCollection UpdateAnchorPointsPosition(InkCanvas surfaceDessin)
        {
            var selectedStrokes = surfaceDessin.GetSelectedStrokes();
            var shapes = selectedStrokes.Where(x => x is AbstractShapeStroke);
            var affectedStrokes = new StrokeCollection();

            foreach (AbstractShapeStroke shape in shapes)
            {
                foreach (var conn in shape.InConnections)
                {
                    var newAnchorPoint = shape.AnchorPoints[conn.Value];
                    var lineStroke = surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid == conn.Key);
                    if (lineStroke != null)
                    {
                        lineStroke.StylusPoints[1] = new StylusPoint(newAnchorPoint.X, newAnchorPoint.Y);
                        if (!affectedStrokes.Select(x => (x as AbstractStroke).Guid).Contains(conn.Key)) affectedStrokes.Add(lineStroke);
                    }
                }
                foreach (var conn in shape.OutConnections)
                {
                    var newAnchorPoint = shape.AnchorPoints[conn.Value];
                    var lineStroke = surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid == conn.Key);
                    if (lineStroke != null)
                    {
                        lineStroke.StylusPoints[0] = new StylusPoint(newAnchorPoint.X, newAnchorPoint.Y);
                        if (!affectedStrokes.Select(x => (x as AbstractStroke).Guid).Contains(conn.Key)) affectedStrokes.Add(lineStroke);
                    }
                }
            }

            return affectedStrokes;
        }

        internal void ContextualMenuClick(InkCanvas surfaceDessin, string header, VueModele vm)
        {
            switch (header)
            {
                case "SelectAll":
                    vm.SelectItems(surfaceDessin.Strokes);
                    var list = StrokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    vm.CollaborationClient.CollaborativeSelectAsync(list);
                    break;
                case "InvertSelection":
                    StrokeCollection strokesToSelect = new StrokeCollection();
                    foreach (var stroke in surfaceDessin.Strokes)
                    {
                        if (!surfaceDessin.GetSelectedStrokes().Contains(stroke))
                            strokesToSelect.Add(stroke);
                    }
                    vm.SelectItems(strokesToSelect);
                    list = StrokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    vm.CollaborationClient.CollaborativeSelectAsync(list);
                    break;
                case "InvertColors":
                    InvertStrokesColors(surfaceDessin);
                    list = StrokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    vm.CollaborationClient.CollaborativeDrawAsync(list);
                    break;
                case "TransformAllShapes":
                    TransformAllShapes(surfaceDessin, vm);
                    list = StrokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection(surfaceDessin.Strokes.Where(x => x is AbstractShapeStroke && (!vm.GetOnlineSelection().Values.Any(y => y.Any(z => z.Guid == ((AbstractStroke)x).Guid.ToString()))))));
                    vm.CollaborationClient.CollaborativeDrawAsync(list);
                    break;
                case "TransformAllConnections":
                    TransformAllConnections(surfaceDessin, vm);
                    list = StrokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection(surfaceDessin.Strokes.Where(x => x is AbstractLineStroke && (!vm.GetOnlineSelection().Values.Any(y => y.Any(z => z.Guid == ((AbstractStroke)x).Guid.ToString()))))));
                    vm.CollaborationClient.CollaborativeDrawAsync(list);
                    break;
                case "TransformAllShapesAndConnections":
                    TransformAllShapes(surfaceDessin, vm);
                    TransformAllConnections(surfaceDessin, vm);
                    list = StrokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection(surfaceDessin.Strokes.Where(x => x is AbstractStroke && (!vm.GetOnlineSelection().Values.Any(y => y.Any(z => z.Guid == ((AbstractStroke)x).Guid.ToString()))))));
                    vm.CollaborationClient.CollaborativeDrawAsync(list);
                    break;
            }
        }

        private void InvertStrokesColors(InkCanvas surfaceDessin)
        {
            foreach (AbstractStroke stroke in surfaceDessin.GetSelectedStrokes().Where(x => x is AbstractStroke))
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
            foreach (AbstractShapeStroke stroke in surfaceDessin.Strokes.Where(x => x is AbstractShapeStroke && (!vm.GetOnlineSelection().Values.Any(y => y.Any(z => z.Guid == ((AbstractStroke)x).Guid.ToString())))))
            {
                if (vm.CouleurSelectionneeBordure != "")
                    stroke.SetBorderColor(vm.CouleurSelectionneeBordure);
                if (vm.CouleurSelectionneeRemplissage != "")
                    stroke.SetFillColor(vm.CouleurSelectionneeRemplissage);
                if (vm.SelectedBorder != "")
                    stroke.SetBorderStyle(Tools.DashAssociations[vm.SelectedBorder]);
            }
        }
        private void TransformAllConnections(InkCanvas surfaceDessin, VueModele vm)
        {
            foreach (AbstractLineStroke stroke in surfaceDessin.Strokes.Where(x => x is AbstractLineStroke && (!vm.GetOnlineSelection().Values.Any(y => y.Any(z => z.Guid == ((AbstractStroke)x).Guid.ToString())))))
            {
                if (vm.CouleurSelectionneeBordure != "")
                    stroke.SetBorderColor(vm.CouleurSelectionneeBordure);
                if (vm.CouleurSelectionneeRemplissage != "")
                    stroke.SetFillColor(vm.CouleurSelectionneeRemplissage);
                if (vm.SelectedBorder != "")
                    stroke.SetBorderStyle(Tools.DashAssociations[vm.SelectedBorder]);
            }
        }
    }
}
