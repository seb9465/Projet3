﻿using PolyPaint.Utilitaires;
using System;
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
    public class PhaseStroke : AbstractShapeStroke
    {
        public PhaseStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(pts, surfaceDessin, "Phase", couleurBordure, couleurRemplissage, thicc, dashStyle)
        { }

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
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + Title.Height + 20));
            points.Add(new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + Title.Height + 20));
            points.Add(new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight));
            points = new PointCollection(points.ToList().Select(x => Tools.RotatePoint(x, Center, Rotation)));

            drawingContext.DrawRectangle(Fill, Border, new Rect(
                points[0],
                points[1]
            ));
            drawingContext.DrawRectangle(Brushes.Transparent, Border, new Rect(
                points[2],
                points[3]
            ));

            if (IsDrawingDone)
            {
                drawingContext.PushTransform(new RotateTransform(Rotation, Center.X, Center.Y));
                DrawText(drawingContext);
                drawingContext.Pop();
            }
            DrawAnchorPoints(drawingContext);
        }

        private void DrawText(DrawingContext drawingContext)
        {
            Title.MaxTextWidth = UnrotatedWidth - 20 > 0 ? UnrotatedWidth - 20 : 0;
            drawingContext.DrawText(Title, new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2.0 - Title.Width / 2.0, UnrotatedTopLeft.Y + 10));
        }
    }
}
