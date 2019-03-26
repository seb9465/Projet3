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
            : base(pts, surfaceDessin, "#FFFFFFFF", "#FFFFFFFF")
        {
            Brush = brush;
            SurfaceDessin = surfaceDessin;
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

            drawingContext.DrawRectangle(Brush, null, new Rect(TopLeft, new Point(TopLeft.X + Width, TopLeft.Y + Height)));
        }
    }
}
