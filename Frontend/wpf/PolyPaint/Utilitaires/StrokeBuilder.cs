using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
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
                switch (stroke.ItemType)
                {
                    case ItemTypeEnum.Comment:
                        DrawingStroke = new RectangleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        SetShapeProperties(stroke);
                        break;
                    case ItemTypeEnum.Activity:
                        DrawingStroke = new ActivityStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        SetShapeProperties(stroke);
                        break;
                    case ItemTypeEnum.Artefact:
                        DrawingStroke = new ArtefactStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        SetShapeProperties(stroke);
                        break;
                    case ItemTypeEnum.Phase:
                        DrawingStroke = new PhaseStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        SetShapeProperties(stroke);
                        break;
                    case ItemTypeEnum.Role:
                        DrawingStroke = new RoleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        SetShapeProperties(stroke);
                        break;
                    case ItemTypeEnum.Text:
                        DrawingStroke = new TextStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        SetShapeProperties(stroke);
                        break;
                    case ItemTypeEnum.UmlClass:
                        DrawingStroke = new UmlClassStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());

                        foreach (var method in stroke.Methods)
                            (DrawingStroke as UmlClassStroke).Methods.Add(new Method(method));

                        foreach (var property in stroke.Properties)
                            (DrawingStroke as UmlClassStroke).Properties.Add(new Property(property));

                        SetShapeProperties(stroke);
                        break;
                    case ItemTypeEnum.Agregation:
                        DrawingStroke = new AgregationStroke(pts, surfaceDessin, borderColor.ToString());
                        SetLineProperties(stroke);
                        break;
                    case ItemTypeEnum.Composition:
                        DrawingStroke = new CompositionStroke(pts, surfaceDessin, borderColor.ToString());
                        SetLineProperties(stroke);
                        break;
                    case ItemTypeEnum.Inheritance:
                        DrawingStroke = new InheritanceStroke(pts, surfaceDessin, borderColor.ToString());
                        SetLineProperties(stroke);
                        break;
                    case ItemTypeEnum.BidirectionalAssociation:
                        DrawingStroke = new BidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString());
                        SetLineProperties(stroke);
                        break;
                    case ItemTypeEnum.UnidirectionalAssociation:
                        DrawingStroke = new UnidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString());
                        SetLineProperties(stroke);
                        break;
                    case ItemTypeEnum.Image:
                        BitmapImage biImg = new BitmapImage();
                        MemoryStream ms = new MemoryStream(stroke.ImageBytes);
                        biImg.BeginInit();
                        biImg.StreamSource = ms;
                        biImg.EndInit();
                        ImageSource imgSrc = biImg as ImageSource;
                        ImageBrush brush = new ImageBrush(imgSrc);

                        (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
                        DrawingStroke = new ImageStroke(pts, surfaceDessin, brush);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;


                    default:
                        break;
                }
            }
        }

        private void SetLineProperties(DrawViewModel stroke)
        {
            (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
            (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
            (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
            (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
            (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                stroke.LastElbowPosition.Y);
            (DrawingStroke as ICanvasable).AddToCanvas();
        }

        private void SetShapeProperties(DrawViewModel stroke)
        {
            (DrawingStroke as AbstractStroke).Guid = Guid.Parse(stroke.Guid);
            (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
            (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
            (DrawingStroke as ICanvasable).AddToCanvas();
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
                List<PolyPaintStylusPoint> points = new List<PolyPaintStylusPoint>();
                foreach (StylusPoint point in stroke.StylusPoints.ToList())
                {
                    points.Add(new PolyPaintStylusPoint()
                    {
                        PressureFactor = point.PressureFactor,
                        X = point.X,
                        Y = point.Y,
                    });
                }
                drawingStroke.StylusPoints = points;
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

                if ((stroke as AbstractShapeStroke != null))
                {
                    drawingStroke.ShapeTitle = (stroke as AbstractShapeStroke).TitleString;
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
    }
}
