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
                { typeof(ActivityStroke), ItemTypeEnum.ActivityStroke },
                { typeof(ArtefactStroke), ItemTypeEnum.ArtefactStroke },
                { typeof(PhaseStroke), ItemTypeEnum.PhaseStroke },
                { typeof(RectangleStroke), ItemTypeEnum.RectangleStroke },
                { typeof(RoleStroke), ItemTypeEnum.RoleStroke },
                { typeof(UmlClassStroke), ItemTypeEnum.UmlClassStroke },
                { typeof(TextStroke), ItemTypeEnum.TextStroke },
                { typeof(AgregationStroke), ItemTypeEnum.AgregationStroke },
                { typeof(BidirectionalAssociationStroke), ItemTypeEnum.BidirectionalAssociationStroke },
                { typeof(CompositionStroke), ItemTypeEnum.CompositionStroke},
                { typeof(InheritanceStroke), ItemTypeEnum.InheritanceStroke },
                { typeof(UnidirectionalAssociationStroke), ItemTypeEnum.UnidirectionalAssociationStroke },
                { typeof(ImageStroke), ItemTypeEnum.ImageStroke}
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
                    case ItemTypeEnum.RectangleStroke:
                        DrawingStroke = new RectangleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.ActivityStroke:
                        DrawingStroke = new ActivityStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.ArtefactStroke:
                        DrawingStroke = new ArtefactStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.PhaseStroke:
                        DrawingStroke = new PhaseStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.RoleStroke:
                        DrawingStroke = new RoleStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.TextStroke:
                        DrawingStroke = new TextStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.UmlClassStroke:
                        DrawingStroke = new UmlClassStroke(pts, surfaceDessin, borderColor.ToString(), fillColor.ToString());
                        (DrawingStroke as AbstractShapeStroke).TitleString = stroke.ShapeTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);

                        foreach (var method in stroke.Methods)
                            (DrawingStroke as UmlClassStroke).Methods.Add(new Method(method));

                        foreach (var property in stroke.Properties)
                            (DrawingStroke as UmlClassStroke).Properties.Add(new Property(property));

                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.AgregationStroke:
                        DrawingStroke = new AgregationStroke(pts, surfaceDessin, borderColor.ToString());
                        (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
                        (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                            stroke.LastElbowPosition.Y);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.CompositionStroke:
                        DrawingStroke = new CompositionStroke(pts, surfaceDessin, borderColor.ToString());
                        (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
                        (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                            stroke.LastElbowPosition.Y);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.InheritanceStroke:
                        DrawingStroke = new InheritanceStroke(pts, surfaceDessin, borderColor.ToString());
                        (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
                        (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                            stroke.LastElbowPosition.Y);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.BidirectionalAssociationStroke:
                        DrawingStroke = new BidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString());
                        (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
                        (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                            stroke.LastElbowPosition.Y);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.UnidirectionalAssociationStroke:
                        DrawingStroke = new UnidirectionalAssociationStroke(pts, surfaceDessin, borderColor.ToString());
                        (DrawingStroke as AbstractLineStroke).SourceString = stroke.SourceTitle;
                        (DrawingStroke as AbstractLineStroke).DestinationString = stroke.DestinationTitle;
                        (DrawingStroke as AbstractStroke).SetBorderStyle(Tools.DashAssociations[stroke.BorderStyle]);
                        (DrawingStroke as AbstractLineStroke).LastElbowPosition = new Point(stroke.LastElbowPosition.X,
                                                                                            stroke.LastElbowPosition.Y);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    case ItemTypeEnum.ImageStroke:
                        BitmapImage biImg = new BitmapImage();
                        MemoryStream ms = new MemoryStream(stroke.ImageBytes);
                        biImg.BeginInit();
                        biImg.StreamSource = ms;
                        biImg.EndInit();
                        ImageSource imgSrc = biImg as ImageSource;
                        ImageBrush brush = new ImageBrush(imgSrc);

                        DrawingStroke = new ImageStroke(pts, surfaceDessin, brush);
                        (DrawingStroke as ICanvasable).AddToCanvas();
                        break;
                    

                    default:
                        break;
                }
            }
        }

        public List<DrawViewModel> GetDrawViewModelsFromStrokes(StrokeCollection strokes)
        {
            List<DrawViewModel> viewModels = new List<DrawViewModel>();
            foreach (AbstractStroke stroke in strokes)
            {
                DrawViewModel drawingStroke = new DrawViewModel();
                drawingStroke.Owner = "Utilisateur";
                drawingStroke.ItemType = _strokeTypes[stroke.GetType()];
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
