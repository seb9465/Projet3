using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using PolyPaint.Common.Collaboration;
using PolyPaint.Strokes;
using PolyPaint.VueModeles;

namespace PolyPaint.Utilitaires
{
    public static class StrokeBuilder
    {
        private static ConcurrentDictionary<Type, ItemTypeEnum> _strokeTypes = new ConcurrentDictionary<Type, ItemTypeEnum>(
               new Dictionary<Type, ItemTypeEnum>()
               {
                { typeof(ActivityStroke), ItemTypeEnum.Activity },
                { typeof(ArtefactStroke), ItemTypeEnum.Artefact },
                { typeof(PhaseStroke), ItemTypeEnum.Phase },
                { typeof(RectangleStroke), ItemTypeEnum.Comment },
                { typeof(RoleStroke), ItemTypeEnum.Role },
                { typeof(UmlClassStroke), ItemTypeEnum.UmlClass },
                { typeof(TextStroke), ItemTypeEnum.Text },
                { typeof(AgregationStroke), ItemTypeEnum.Agregation },
                { typeof(BidirectionalAssociationStroke), ItemTypeEnum.BidirectionalAssociation },
                { typeof(CompositionStroke), ItemTypeEnum.Composition},
                { typeof(InheritanceStroke), ItemTypeEnum.Inheritance },
                { typeof(UnidirectionalAssociationStroke), ItemTypeEnum.UnidirectionalAssociation },
                { typeof(LineStroke), ItemTypeEnum.Line },
                { typeof(ImageStroke), ItemTypeEnum.Image}
               }
           );

        public static Stroke DrawingStroke = null;
        public static void BuildStrokesFromDrawViewModels(List<DrawViewModel> customStrokes, InkCanvas surfaceDessin)
        {
            foreach (var stroke in customStrokes)
            {
                StylusPointCollection pts = new StylusPointCollection();

                foreach (PolyPaintStylusPoint point in stroke.StylusPoints)
                {
                    pts.Add(new StylusPoint()
                    {
                        X = point.X,
                        Y = point.Y,
                        PressureFactor = point.PressureFactor,
                    });
                }

                Color fillColor = new Color
                {
                    A = stroke.FillColor.A,
                    B = stroke.FillColor.B,
                    G = stroke.FillColor.G,
                    R = stroke.FillColor.R
                };

                Color borderColor = new Color
                {
                    A = stroke.BorderColor.A,
                    B = stroke.BorderColor.B,
                    G = stroke.BorderColor.G,
                    R = stroke.BorderColor.R
                };

                var thicc = stroke.BorderThickness;

                switch (stroke.ItemType)
                {
                    case ItemTypeEnum.Comment:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingCommentStroke))
                        {
                            DrawingStroke = existingCommentStroke;
                            ChangeConstructProperties(existingCommentStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new RectangleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Activity:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingActStroke))
                        {
                            DrawingStroke = existingActStroke;
                            ChangeConstructProperties(existingActStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new ActivityStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Artefact:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingArtStroke))
                        {
                            DrawingStroke = existingArtStroke;
                            ChangeConstructProperties(existingArtStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new ArtefactStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Phase:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingPhaseStroke))
                        {
                            DrawingStroke = existingPhaseStroke;
                            ChangeConstructProperties(existingPhaseStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new PhaseStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Role:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingRoleStroke))
                        {
                            DrawingStroke = existingRoleStroke;
                            ChangeConstructProperties(existingRoleStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new RoleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Text:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingTextStroke))
                        {
                            DrawingStroke = existingTextStroke;
                            ChangeConstructProperties(existingTextStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new TextStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.UmlClass:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingUmlStroke))
                        {
                            DrawingStroke = existingUmlStroke;
                            ChangeConstructProperties(existingUmlStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new UmlClassStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }

                        (DrawingStroke as UmlClassStroke).Methods = new ObservableCollection<Method>(stroke.Methods.Select(x => new Method(x)));
                        (DrawingStroke as UmlClassStroke).Properties = new ObservableCollection<Property>(stroke.Properties.Select(x => new Property(x)));

                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Agregation:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingAggStroke))
                        {
                            DrawingStroke = existingAggStroke;
                            ChangeConstructProperties(existingAggStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new AgregationStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetLineProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Composition:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingCompStroke))
                        {
                            DrawingStroke = existingCompStroke;
                            ChangeConstructProperties(existingCompStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new CompositionStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetLineProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Inheritance:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingInhStroke))
                        {
                            DrawingStroke = existingInhStroke;
                            ChangeConstructProperties(existingInhStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new InheritanceStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetLineProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.BidirectionalAssociation:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingBiStroke))
                        {
                            DrawingStroke = existingBiStroke;
                            ChangeConstructProperties(existingBiStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new BidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetLineProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.UnidirectionalAssociation:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingUniStroke))
                        {
                            DrawingStroke = existingUniStroke;
                            ChangeConstructProperties(existingUniStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new UnidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetLineProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Line:
                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingLineStroke))
                        {
                            DrawingStroke = existingLineStroke;
                            ChangeConstructProperties(existingLineStroke, pts, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        else
                        {
                            DrawingStroke = new LineStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        }
                        SetLineProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;
                    case ItemTypeEnum.Image:
                        BitmapImage biImg = new BitmapImage();
                        MemoryStream ms = new MemoryStream(stroke.ImageBytes);
                        biImg.BeginInit();
                        biImg.StreamSource = ms;
                        biImg.EndInit();
                        ImageSource imgSrc = biImg as ImageSource;
                        ImageBrush brush = new ImageBrush(imgSrc);

                        if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingImageStroke))
                        {
                            DrawingStroke = existingImageStroke;
                            DrawingStroke.StylusPoints = pts;
                            (DrawingStroke as ImageStroke).Brush = brush;
                        }
                        else
                        {
                            DrawingStroke = new ImageStroke(pts, surfaceDessin, brush);
                        }
                        SetShapeProperties(stroke, surfaceDessin, ref DrawingStroke);
                        break;


                    default:
                        break;
                }
            }

            AddInOutConnections(customStrokes, surfaceDessin);
        }

        private static void AddInOutConnections(List<DrawViewModel> customStrokes, InkCanvas surfaceDessin)
        {
            foreach (AbstractShapeStroke shape in surfaceDessin.Strokes.Where(x => x is AbstractShapeStroke))
            {
                var dvm = customStrokes.FirstOrDefault(x => x.Guid == shape.Guid.ToString());
                if (dvm != null && dvm.InConnections != null)
                {
                    foreach (var connection in dvm.InConnections)
                    {
                        AnchorPosition pos = (AnchorPosition)Enum.Parse(typeof(AnchorPosition), connection[1], true);
                        var stroke = (AbstractLineStroke)surfaceDessin.Strokes.Where(x => x is AbstractLineStroke).FirstOrDefault(x => (x as AbstractLineStroke).Guid.ToString() == connection[0]);
                        if (stroke != null)
                            shape.InConnections.TryAdd(stroke.Guid, pos);
                        var connStroke = surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid.ToString() == connection[0]);
                        if (connStroke != null)
                        {
                            (connStroke as AbstractLineStroke).TrySnap();
                        }
                    }
                }
                if (dvm != null && dvm.OutConnections != null)
                {
                    foreach (var connection in dvm.OutConnections)
                    {
                        AnchorPosition pos = (AnchorPosition)Enum.Parse(typeof(AnchorPosition), connection[1], true);
                        var stroke = (AbstractLineStroke)surfaceDessin.Strokes.Where(x => x is AbstractLineStroke).FirstOrDefault(x => (x as AbstractLineStroke).Guid.ToString() == connection[0]);
                        if (stroke != null)
                            shape.OutConnections.TryAdd(stroke.Guid, pos);
                        var connStroke = surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid.ToString() == connection[0]);
                        if (connStroke != null)
                        {
                            (connStroke as AbstractLineStroke).TrySnap();
                        }
                    }
                }
            }
        }

        private static void ChangeConstructProperties(AbstractStroke existingStroke, StylusPointCollection pts, string borderColor, string fillColor, double thicc, DashStyle style)
        {
            existingStroke.StylusPoints = pts;
            existingStroke.SetBorderColor(borderColor);
            existingStroke.SetFillColor(fillColor);
            existingStroke.SetBorderThickness(thicc);
            existingStroke.SetBorderStyle(style);
        }

        private static void SetLineProperties(DrawViewModel stroke, InkCanvas surfaceDessin, ref Stroke DrawingStroke)
        {
            (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
            (DrawingStroke as AbstractStroke).TitleString = stroke.ShapeTitle;
            (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
            (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
            (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
            var elbow = new Point(stroke.LastElbowPosition.X, stroke.LastElbowPosition.Y);
            var spoints = (DrawingStroke as AbstractLineStroke).StylusPoints;
            (DrawingStroke as AbstractLineStroke).StylusPoints = new StylusPointCollection() { spoints[0], spoints[1], new StylusPoint(elbow.X, elbow.Y) };
            (DrawingStroke as AbstractLineStroke).LastElbowPosition = elbow;

            if (TryGetByGuid(surfaceDessin, Guid.Parse(stroke.Guid), out var existingStroke))
            {
                DrawingStroke = existingStroke;
                (DrawingStroke as ICanvasable).Redraw();
            }
            else
            {
                (DrawingStroke as ICanvasable).AddToCanvas();
            }
        }

        private static void SetShapeProperties(DrawViewModel stroke, InkCanvas surfaceDessin, ref Stroke DrawingStroke)
        {
            (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
            (DrawingStroke as AbstractStroke).Rotation = stroke.Rotation;

            var stylusPoint0 = Tools.RotatePoint((DrawingStroke as AbstractStroke).StylusPoints[0].ToPoint(), (DrawingStroke as AbstractStroke).Center, (DrawingStroke as AbstractStroke).Rotation);
            var stylusPoint1 = Tools.RotatePoint((DrawingStroke as AbstractStroke).StylusPoints[1].ToPoint(), (DrawingStroke as AbstractStroke).Center, (DrawingStroke as AbstractStroke).Rotation);
            (DrawingStroke as AbstractStroke).StylusPoints[0] = new StylusPoint(stylusPoint0.X, stylusPoint0.Y);
            (DrawingStroke as AbstractStroke).StylusPoints[1] = new StylusPoint(stylusPoint1.X, stylusPoint1.Y);

            (DrawingStroke as AbstractStroke).TitleString = stroke.ShapeTitle;

            (DrawingStroke as ICanvasable).AddToCanvas();
        }

        private static bool TryGetByGuid(InkCanvas surfaceDessin, Guid guid, out AbstractStroke stroke)
        {
            stroke = (AbstractStroke)surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid == guid);
            return stroke != null;
        }

        public static List<DrawViewModel> GetDrawViewModelsFromStrokes(StrokeCollection strokes)
        {
            List<DrawViewModel> viewModels = new List<DrawViewModel>();
            foreach (AbstractStroke stroke in strokes)
            {
                DrawViewModel drawingStroke = new DrawViewModel();
                drawingStroke.Owner = "Utilisateur";
                drawingStroke.ItemType = _strokeTypes[stroke.GetType()];
                drawingStroke.Guid = stroke.Guid.ToString();
                drawingStroke.Rotation = stroke.Rotation;

                PolyPaintStylusPoint stylusPoint0;
                PolyPaintStylusPoint stylusPoint1;
                if (stroke is AbstractLineStroke)
                {
                    stylusPoint0 = new PolyPaintStylusPoint(stroke.StylusPoints[0].X, stroke.StylusPoints[0].Y) { PressureFactor = stroke.StylusPoints[0].PressureFactor };
                    stylusPoint1 = new PolyPaintStylusPoint(stroke.StylusPoints[1].X, stroke.StylusPoints[1].Y) { PressureFactor = stroke.StylusPoints[1].PressureFactor };
                }
                else
                {
                    stylusPoint0 = new PolyPaintStylusPoint(stroke.UnrotatedTopLeft.X, stroke.UnrotatedTopLeft.Y) { PressureFactor = stroke.StylusPoints[0].PressureFactor };
                    var bottomRight = new Point(stroke.UnrotatedTopLeft.X + stroke.UnrotatedWidth, stroke.UnrotatedTopLeft.Y + stroke.UnrotatedHeight);
                    stylusPoint1 = new PolyPaintStylusPoint(bottomRight.X, bottomRight.Y) { PressureFactor = stroke.StylusPoints[1].PressureFactor };
                }
                drawingStroke.StylusPoints = new List<PolyPaintStylusPoint>() { stylusPoint0, stylusPoint1 };

                drawingStroke.FillColor = new PolyPaintColor()
                {
                    A = (stroke.Fill as SolidColorBrush).Color.A,
                    B = (stroke.Fill as SolidColorBrush).Color.B,
                    G = (stroke.Fill as SolidColorBrush).Color.G,
                    R = (stroke.Fill as SolidColorBrush).Color.R,
                };
                drawingStroke.BorderColor = new PolyPaintColor()
                {
                    A = (stroke.Border.Brush as SolidColorBrush).Color.A,
                    B = (stroke.Border.Brush as SolidColorBrush).Color.B,
                    G = (stroke.Border.Brush as SolidColorBrush).Color.G,
                    R = (stroke.Border.Brush as SolidColorBrush).Color.R,
                };
                drawingStroke.BorderThickness = stroke.Border.Thickness;
                drawingStroke.BorderStyle = Tools.DashAssociations.First(x => x.Value.Dashes.Count == stroke.BorderStyle.Dashes.Count).Key;
                drawingStroke.ShapeTitle = (stroke as AbstractStroke).TitleString;

                if (stroke is AbstractShapeStroke)
                {
                    if (stroke is UmlClassStroke)
                    {
                        drawingStroke.Methods = new List<string>();
                        foreach (var method in (stroke as UmlClassStroke).Methods)
                            drawingStroke.Methods.Add(method.Title);

                        drawingStroke.Properties = new List<string>();
                        foreach (var property in (stroke as UmlClassStroke).Properties)
                            drawingStroke.Properties.Add(property.Title);
                    }
                    drawingStroke.InConnections = new List<List<string>>((stroke as AbstractShapeStroke).InConnections.Select(x => new List<string>() { x.Key.ToString(), x.Value.ToString().ToLower() }));
                    drawingStroke.OutConnections = new List<List<string>>((stroke as AbstractShapeStroke).OutConnections.Select(x => new List<string>() { x.Key.ToString(), x.Value.ToString().ToLower() }));
                }

                if (stroke is AbstractLineStroke)
                {
                    drawingStroke.SourceTitle = (stroke as AbstractLineStroke).SourceString;
                    drawingStroke.DestinationTitle = (stroke as AbstractLineStroke).DestinationString;
                    drawingStroke.LastElbowPosition = new PolyPaintStylusPoint((stroke as AbstractLineStroke).LastElbowPosition.X, (stroke as AbstractLineStroke).LastElbowPosition.Y);
                }

                if (stroke is ImageStroke)
                {
                    byte[] bytes = null;
                    ImageSource image = (stroke as ImageStroke).Brush.ImageSource;
                    BitmapSource bitmapSource = image as BitmapSource;
                    PngBitmapEncoder encoder = new PngBitmapEncoder();
                    if (bitmapSource != null)
                    {
                        encoder.Frames.Add(BitmapFrame.Create(bitmapSource));

                        using (var stream = new MemoryStream())
                        {
                            encoder.Save(stream);
                            bytes = stream.ToArray();
                        }
                    }
                    drawingStroke.ImageBytes = bytes;
                }
                viewModels.Add(drawingStroke);
            }
            return viewModels;
        }
    }
}
