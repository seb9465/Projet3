﻿using System.Windows.Input;
using System.Windows.Controls;
using System.Windows;
using System.Windows.Media;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using PolyPaint.Utilitaires;
using System;

namespace PolyPaint.Strokes
{
    public abstract class AbstractShapeStroke : AbstractStroke
    {
        public ConcurrentDictionary<AnchorPosition, Point> AnchorPoints { get; set; }

        public ConcurrentDictionary<Guid, AnchorPosition> InConnections { get; set; }
        public ConcurrentDictionary<Guid, AnchorPosition> OutConnections { get; set; }

        public AbstractShapeStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string title, string couleurBordure, string couleurRemplissage, double thicc, DashStyle dashStyle)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            AnchorPoints = new ConcurrentDictionary<AnchorPosition, Point>(
                new Dictionary<AnchorPosition, Point>()
                {
                    { AnchorPosition.Bottom, new Point() },
                    { AnchorPosition.Left, new Point() },
                    { AnchorPosition.Right, new Point() },
                    { AnchorPosition.Top, new Point() }
                }
            );

            InConnections = new ConcurrentDictionary<Guid, AnchorPosition>();
            OutConnections = new ConcurrentDictionary<Guid, AnchorPosition>();

            Title = new FormattedText(title, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);
        }

        protected virtual void DrawAnchorPoints(DrawingContext drawingContext)
        {
            SolidColorBrush brush = new SolidColorBrush(Colors.Gray);

            AnchorPoints[AnchorPosition.Top] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y);
            AnchorPoints[AnchorPosition.Bottom] = new Point(UnrotatedTopLeft.X + UnrotatedWidth / 2, UnrotatedTopLeft.Y + UnrotatedHeight);
            AnchorPoints[AnchorPosition.Right] = new Point(UnrotatedTopLeft.X + UnrotatedWidth, UnrotatedTopLeft.Y + UnrotatedHeight / 2);
            AnchorPoints[AnchorPosition.Left] = new Point(UnrotatedTopLeft.X, UnrotatedTopLeft.Y + UnrotatedHeight / 2.0);
            AnchorPoints = new ConcurrentDictionary<AnchorPosition, Point>
            (
                AnchorPoints.ToDictionary(x => x.Key, x => Tools.RotatePoint(x.Value, Center, Rotation))
            );

            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Top], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Bottom], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Right], 2, 2);
            drawingContext.DrawEllipse(brush, null, AnchorPoints[AnchorPosition.Left], 2, 2);
        }
    }
}