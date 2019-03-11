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
            DrawAnchorPoints(drawingContext);
            //SurfaceDessin.Children.Add(Titre);

            //InkCanvas.SetLeft(Titre, (stp.X + sp.X) / 2);
            //InkCanvas.SetTop(Titre, (stp.Y + sp.Y) / 2);
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            Point topLeft = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            double width = (StylusPoints[1].X - StylusPoints[0].X);
            double height = (StylusPoints[1].Y - StylusPoints[0].Y);

            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X + width / 2, topLeft.Y), 2, 2);
            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X + width / 2, topLeft.Y + height), 2, 2);
            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X + width, topLeft.Y + height / 2), 2, 2);
            drawingContext.DrawEllipse(brush, null, new Point(topLeft.X, topLeft.Y + height / 2), 2, 2);

        }

        public void AddToCanvas()
        {
            SurfaceDessin.Strokes.Add(Clone());
            //SurfaceDessin.Children.Add(Tools.DeepCopy(Titre));
        }

        public void RemoveFromCanvas()
        {
            SurfaceDessin.Strokes.Remove(this);
            //SurfaceDessin.Children.Remove(Titre);
        }
    }
}
