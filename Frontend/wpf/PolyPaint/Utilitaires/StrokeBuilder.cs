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
    public class StrokeBuilder
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

        public Stroke DrawingStroke = null;
        public void BuildStrokesFromDrawViewModels(List<DrawViewModel> customStrokes, InkCanvas surfaceDessin)
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
        }

        private void ChangeConstructProperties(AbstractStroke existingStroke, StylusPointCollection pts, string borderColor, string fillColor, double thicc, DashStyle style)
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
            (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                stroke.LastElbowPosition.Y);

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
        private static void SetLineProperties(DrawViewModel stroke, ref Stroke DrawingStroke)
        {
            (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
            (DrawingStroke as AbstractStroke).TitleString = stroke.ShapeTitle;
            (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
            (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
            (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
            (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                stroke.LastElbowPosition.Y);
        }

        private static void SetShapeProperties(DrawViewModel stroke, InkCanvas surfaceDessin, ref Stroke DrawingStroke)
        {
            (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
            (DrawingStroke as AbstractStroke).Rotation = stroke.Rotation;
            (DrawingStroke as AbstractStroke).TitleString = stroke.ShapeTitle;

            (DrawingStroke as ICanvasable).AddToCanvas();
        }
        private static void SetShapeProperties(DrawViewModel stroke, ref Stroke DrawingStroke)
        {
            (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
            (DrawingStroke as AbstractStroke).Rotation = stroke.Rotation;
            (DrawingStroke as AbstractStroke).TitleString = stroke.ShapeTitle;
        }

        private static bool TryGetByGuid(InkCanvas surfaceDessin, Guid guid, out AbstractStroke stroke)
        {
            stroke = (AbstractStroke)surfaceDessin.Strokes.FirstOrDefault(x => (x as AbstractStroke).Guid == guid);
            return stroke != null;
        }

        public List<DrawViewModel> GetDrawViewModelsFromStrokes(StrokeCollection strokes)
        {
            List<DrawViewModel> viewModels = new List<DrawViewModel>();
            foreach (AbstractStroke stroke in strokes)
            {
                DrawViewModel drawingStroke = new DrawViewModel();
                drawingStroke.Owner = "Utilisateur";
                drawingStroke.ItemType = _strokeTypes[stroke.GetType()];
                drawingStroke.Guid = stroke.Guid.ToString();
                drawingStroke.Rotation = stroke.Rotation;

                var stylusPoint0 = new PolyPaintStylusPoint() { PressureFactor = stroke.StylusPoints[0].PressureFactor, X = stroke.TopLeft.X, Y = stroke.TopLeft.Y };
                var bottomRight = new Point(stroke.TopLeft.X + stroke.Width, stroke.TopLeft.Y + stroke.Height);
                var stylusPoint1 = new PolyPaintStylusPoint() { PressureFactor = stroke.StylusPoints[1].PressureFactor, X = bottomRight.X, Y = bottomRight.Y };
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
                drawingStroke.BorderStyle = Tools.DashAssociations.First(x => x.Value == stroke.BorderStyle).Key;
                drawingStroke.ShapeTitle = (stroke as AbstractStroke).TitleString;

                if ((stroke as AbstractShapeStroke != null))
                {
                    if (stroke as UmlClassStroke != null)
                    {
                        drawingStroke.Methods = new List<string>();
                        foreach (var method in (stroke as UmlClassStroke).Methods)
                            drawingStroke.Methods.Add(method.Title);

                        drawingStroke.Properties = new List<string>();
                        foreach (var property in (stroke as UmlClassStroke).Properties)
                            drawingStroke.Properties.Add(property.Title);
                    }
                }

                if ((stroke as AbstractLineStroke != null))
                {
                    drawingStroke.SourceTitle = (stroke as AbstractLineStroke).SourceString;
                    drawingStroke.DestinationTitle = (stroke as AbstractLineStroke).DestinationString;
                    drawingStroke.LastElbowPosition = new PolyPaintStylusPoint()
                    {
                        X = (stroke as AbstractLineStroke).LastElbowPosition.X,
                        Y = (stroke as AbstractLineStroke).LastElbowPosition.Y,
                    };
                }

                if ((stroke as ImageStroke) != null)
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

        public static StrokeCollection BuildStrokeCollectionFromDVMs(List<DrawViewModel> drawViewModels, InkCanvas surfaceDessin)
        {
            var sCollection = new StrokeCollection();
            foreach (var stroke in drawViewModels)
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
                Stroke DrawingStroke;

                switch (stroke.ItemType)
                {
                    case ItemTypeEnum.Comment:
                        DrawingStroke = new RectangleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Activity:
                        DrawingStroke = new ActivityStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Artefact:
                        DrawingStroke = new ArtefactStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Phase:
                        DrawingStroke = new PhaseStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Role:
                        DrawingStroke = new RoleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Text:
                        DrawingStroke = new TextStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.UmlClass:
                        DrawingStroke = new UmlClassStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);

                        (DrawingStroke as UmlClassStroke).Methods = new ObservableCollection<Method>(stroke.Methods.Select(x => new Method(x)));
                        (DrawingStroke as UmlClassStroke).Properties = new ObservableCollection<Property>(stroke.Properties.Select(x => new Property(x)));

                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Agregation:
                        DrawingStroke = new AgregationStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetLineProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Composition:
                        DrawingStroke = new CompositionStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetLineProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Inheritance:
                        DrawingStroke = new InheritanceStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetLineProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.BidirectionalAssociation:
                        DrawingStroke = new BidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetLineProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.UnidirectionalAssociation:
                        DrawingStroke = new UnidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetLineProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Line:
                        DrawingStroke = new LineStroke(pts, surfaceDessin, borderColor.ToString(), thicc, Tools.DashAssociations[stroke.BorderStyle]);
                        SetLineProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    case ItemTypeEnum.Image:
                        BitmapImage biImg = new BitmapImage();
                        MemoryStream ms = new MemoryStream(stroke.ImageBytes);
                        biImg.BeginInit();
                        biImg.StreamSource = ms;
                        biImg.EndInit();
                        ImageSource imgSrc = biImg as ImageSource;
                        ImageBrush brush = new ImageBrush(imgSrc);

                        DrawingStroke = new ImageStroke(pts, surfaceDessin, brush);
                        SetShapeProperties(stroke, ref DrawingStroke);
                        sCollection.Add(DrawingStroke);
                        break;
                    default:
                        break;
                }
            }
            return sCollection;
        }
    }
}
