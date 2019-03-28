using PolyPaint.Utilitaires;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractStroke : Stroke, ICanvasable, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public bool IsDrawingDone { get; set; }

        public Point TopLeft { get; set; }
        public Point Center { get { return new Point(TopLeft.X + Width / 2.0, TopLeft.Y + Height / 2.0); } }
        public double Width { get; set; }
        public double Height { get; set; }

        public List<Point> UnrotatedStylusPoints
        {
            get
            {
                return StylusPoints.ToList().Select(x => Tools.RotatePoint(x.ToPoint(), Center, -Rotation)).ToList();
            }
        }
        public Point UnrotatedTopLeft
        {
            get
            {
                return new Point(UnrotatedStylusPoints[0].X <= UnrotatedStylusPoints[1].X ? UnrotatedStylusPoints[0].X : UnrotatedStylusPoints[1].X,
                UnrotatedStylusPoints[0].Y <= UnrotatedStylusPoints[1].Y ? UnrotatedStylusPoints[0].Y : UnrotatedStylusPoints[1].Y);
            }
        }
        public double UnrotatedWidth { get { return Math.Abs(UnrotatedStylusPoints[1].X - UnrotatedStylusPoints[0].X); } }
        public double UnrotatedHeight { get { return Math.Abs(UnrotatedStylusPoints[1].Y - UnrotatedStylusPoints[0].Y); } }
        public double Rotation { get; set; }

        public Brush Fill { get; set; }
        public Pen Border { get; set; }
        public DashStyle BorderStyle { get { return Border.DashStyle; } }
        public Color BorderColor { get { return (Border.Brush as SolidColorBrush).Color; } }
        public Color FillColor { get { return (Fill as SolidColorBrush).Color; } }

        public Guid Guid { get; set; } = Guid.NewGuid();

        protected InkCanvas SurfaceDessin { get; set; }

        public AbstractStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc)
            : base(pts)
        {
            TopLeft = new Point();
            Width = 0;
            Height = 0;

            couleurBordure = couleurBordure == "" ? "#FF000000" : couleurBordure;
            couleurRemplissage = couleurRemplissage == "" ? "#FFFFFFFF" : couleurRemplissage;

            Border = new Pen(new SolidColorBrush((Color)ColorConverter.ConvertFromString(couleurBordure)), thicc);
            Fill = new SolidColorBrush((Color)ColorConverter.ConvertFromString(couleurRemplissage));

            IsDrawingDone = false;

            SurfaceDessin = surfaceDessin;
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public void AddToCanvas()
        {
            RemoveFromCanvas();
            var clone = Clone();
            (clone as AbstractStroke).IsDrawingDone = true;
            SurfaceDessin.Strokes.Add(clone);
        }

        public void RemoveFromCanvas()
        {
            var stroke = SurfaceDessin.Strokes.FirstOrDefault(x => x is AbstractStroke && (x as AbstractStroke).Guid == Guid);
            if (stroke != null)
            {
                SurfaceDessin.Strokes.Remove(stroke);
            }
        }

        public void SetBorderStyle(DashStyle style)
        {
            Border.DashStyle = style;
            Redraw();
        }

        public void SetBorderThickness(double thickness)
        {
            Border.Thickness = thickness;
            Redraw();
        }

        public void SetBorderColor(string color)
        {
            var dashStyle = Border.DashStyle;
            Border = new Pen(new SolidColorBrush((Color)ColorConverter.ConvertFromString(color)), Border.Thickness);
            Border.DashStyle = dashStyle;
            Redraw();
        }

        public void SetBorderThickness(int thicc)
        {
            Border.Thickness = thicc;
            Redraw();
        }

        public void SetFillColor(string color)
        {
            Fill = new SolidColorBrush((Color)ColorConverter.ConvertFromString(color));
            Redraw();
        }

        public void Redraw()
        {
            OnInvalidated(new EventArgs());
        }

        // Draw a polyline.
        protected void DrawPolyline(DrawingContext drawingContext,
            Brush brush, Pen pen, Point[] points, FillRule fill_rule)
        {
            DrawPolygonOrPolyline(
                drawingContext, brush, pen, points, fill_rule, false);
        }

        // Draw a polygon or polyline.
        private void DrawPolygonOrPolyline(
            DrawingContext drawingContext,
            Brush brush, Pen pen, Point[] points, FillRule fill_rule,
            bool draw_polygon)
        {
            // Make a StreamGeometry to hold the drawing objects.
            StreamGeometry geo = new StreamGeometry();
            geo.FillRule = fill_rule;

            // Open the context to use for drawing.
            using (StreamGeometryContext context = geo.Open())
            {
                // Start at the first point.
                context.BeginFigure(points[0], true, draw_polygon);

                // Add the points after the first one.
                context.PolyLineTo(points.Skip(1).ToArray(), true, false);
            }

            // Draw.
            drawingContext.DrawGeometry(brush, pen, geo);
        }
    }
}
