using PolyPaint.Utilitaires;
using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Linq;

namespace PolyPaint.Strokes
{
    public class ImageStroke : AbstractStroke
    {
        public ImageBrush Brush { get; set; }
        public ImageStroke(StylusPointCollection pts, InkCanvas surfaceDessin, ImageBrush brush)
            : base(pts, surfaceDessin, "#FFFFFFFF", "#FFFFFFFF", 0, DashStyles.Solid)
        {
            Brush = brush;
            SurfaceDessin = surfaceDessin;
            TitleString = "";
        }

        protected override void DrawCore(DrawingContext drawingContext, DrawingAttributes drawingAttributes)
        {
            if (drawingContext == null)
            {
                throw new ArgumentNullException("drawingContext");
            }
            if (null == drawingAttributes)
            {
                throw new ArgumentNullException("drawingAttributes");
            }

            TopLeft = new Point(StylusPoints[0].X <= StylusPoints[1].X ? StylusPoints[0].X : StylusPoints[1].X,
                StylusPoints[0].Y <= StylusPoints[1].Y ? StylusPoints[0].Y : StylusPoints[1].Y);
            Width = Math.Abs(StylusPoints[1].X - StylusPoints[0].X);
            Height = Math.Abs(StylusPoints[1].Y - StylusPoints[0].Y);

            PointCollection points = new PointCollection();
            points.Add(UnrotatedTopLeft);
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight));
            points = new PointCollection(points.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)));

            TransformGroup tg = new TransformGroup();
            tg.Children.Add(new RotateTransform(Rotation, Center.X, Center.Y));
            if (Rotation / 90 % 2 != 0)
                tg.Children.Add(new ScaleTransform(Width / Height, Height / Width, Center.X, Center.Y));
            Brush.Transform = tg;

            drawingContext.DrawRectangle(Brush, null, new Rect(
                points[0],
                points[1]
            ));
        }
    }
}
