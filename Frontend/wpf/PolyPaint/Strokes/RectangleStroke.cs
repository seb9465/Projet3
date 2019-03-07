using PolyPaint.Utilitaires;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class RectangleStroke : Stroke, ICanvasable
    {

        //public string Titre { get; set; }
        public TextBox Titre { get; set; }
        public InkCanvas SurfaceDessin { get; set; }

        public RectangleStroke(StylusPointCollection pts, string titre, InkCanvas surfaceDessin)
            : base(pts)
        {
            StylusPoints = pts;
            Titre = new TextBox();
            Titre.Text = titre;

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
            SolidColorBrush brush = new SolidColorBrush(drawingAttributes.Color);
            brush.Freeze();
            StylusPoint stp = StylusPoints[0];
            StylusPoint sp = StylusPoints[1];

            drawingContext.DrawRectangle(brush, null, new Rect(new Point(sp.X, sp.Y), new Point(stp.X, stp.Y)));
            SurfaceDessin.Children.Add(Titre);

            InkCanvas.SetLeft(Titre, (stp.X + sp.X) / 2);
            InkCanvas.SetTop(Titre, (stp.Y + sp.Y) / 2);
        }

        public void AddToCanvas()
        {
            SurfaceDessin.Strokes.Add(Clone());
            SurfaceDessin.Children.Add(Tools.DeepCopy(Titre));
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
            SurfaceDessin.Children.Remove(Titre);
        }
    }
}
