﻿using PolyPaint.Utilitaires;
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
    public class RoleStroke : AbstractStroke
    {
        public RoleStroke(StylusPointCollection pts, InkCanvas surfaceDessin)
            : base(pts, surfaceDessin, "Role")
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

            drawingContext.DrawEllipse(Fill, Border, new Point(TopLeft.X + Width / 2.0, TopLeft.Y + 1.0 / 8.0 * Height), 1.0 / 4.0 * Width, 1.0 / 8.0 * Height);
            drawingContext.DrawLine(Border, new Point(TopLeft.X + Width / 2.0, TopLeft.Y + 1.0 / 4.0 * Height), new Point(TopLeft.X + Width / 2.0, TopLeft.Y + 3.0 / 4.0 * Height));
            drawingContext.DrawLine(Border, new Point(TopLeft.X, TopLeft.Y + 3.0 / 8.0 * Height), new Point(TopLeft.X + Width, TopLeft.Y + 3.0 / 8.0 * Height));
            drawingContext.DrawLine(Border, new Point(TopLeft.X + Width / 2.0, TopLeft.Y + 3.0 / 4.0 * Height), new Point(TopLeft.X, TopLeft.Y + Height));
            drawingContext.DrawLine(Border, new Point(TopLeft.X + Width / 2.0, TopLeft.Y + 3.0 / 4.0 * Height), new Point(TopLeft.X + Width, TopLeft.Y + Height));

            if (IsDrawingDone)
                DrawText(drawingContext);
            DrawAnchorPoints(drawingContext);
        }

        private void DrawText(DrawingContext drawingContext)
        {
            drawingContext.DrawText(Title, new Point(TopLeft.X + Width / 2.0 - Title.Width / 2.0, TopLeft.Y + Height + 10));
        }

        private void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[0] = new Point(TopLeft.X + Width / 2, TopLeft.Y);
            AnchorPoints[1] = new Point(TopLeft.X + Width / 2, TopLeft.Y + Height);
            AnchorPoints[2] = new Point(TopLeft.X + Width, TopLeft.Y + Height / 2);
            AnchorPoints[3] = new Point(TopLeft.X, TopLeft.Y + Height / 2);

            drawingContext.DrawEllipse(brush, null, AnchorPoints[0], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[1], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[2], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[3], 2, 2);

        }
    }
}