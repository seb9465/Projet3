﻿using PolyPaint.Utilitaires;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class BidirectionalAssociationStroke : AbstractLineStroke
    {
        public BidirectionalAssociationStroke(StylusPointCollection pts, InkCanvas surfaceDessin, string couleurBordure)
            : base(pts, surfaceDessin, "0..0", "0..0", couleurBordure, "#FF000000")
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

            AttachToAnchors();

            StylusPoint stp = StylusPoints[0];
            StylusPoint sp = StylusPoints[1];

            int arrowLength = 10;
            double rad = (Math.PI / 180) * 35;
            double phi2 = (Math.PI / 180) * -35;

            double startDx = stp.X - sp.X;
            double startDy = stp.Y - sp.Y;
            double startTheta = Math.Atan2(startDy, startDx);

            double startX = stp.X - arrowLength * Math.Cos(startTheta + rad);
            double startY = stp.Y - arrowLength * Math.Sin(startTheta + rad);

            double startX2 = stp.X - arrowLength * Math.Cos(startTheta + phi2);
            double startY2 = stp.Y - arrowLength * Math.Sin(startTheta + phi2);

            double endDx = sp.X - stp.X;
            double endDy = sp.Y - stp.Y;
            double endTheta = Math.Atan2(endDy, endDx);

            double endX = sp.X - arrowLength * Math.Cos(endTheta + rad);
            double endY = sp.Y - arrowLength * Math.Sin(endTheta + rad);

            double endX2 = sp.X - arrowLength * Math.Cos(endTheta + phi2);
            double endY2 = sp.Y - arrowLength * Math.Sin(endTheta + phi2);

            Point point2 = new Point(startX, startY);
            Point point3 = new Point(stp.X, stp.Y);
            Point point4 = new Point(startX2, startY2);


            Point point7 = new Point(endX, endY);
            Point point8 = new Point(sp.X, sp.Y);
            Point point9 = new Point(endX2, endY2);

            StreamGeometry streamGeometry1 = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry1.Open())
            {
                geometryContext.BeginFigure(stp.ToPoint(), true, true);
                PointCollection points = new PointCollection
                                             {
                                                 point2,
                                                 point3,
                                                 point4
                                             };
                geometryContext.PolyLineTo(points, true, true);
            }

            StreamGeometry streamGeometry2 = new StreamGeometry();
            using (StreamGeometryContext geometryContext = streamGeometry2.Open())
            {
                geometryContext.BeginFigure(sp.ToPoint(), true, true);
                PointCollection points = new PointCollection
                                             {
                                                 point7,
                                                 point8,
                                                 point9
                                             };
                geometryContext.PolyLineTo(points, true, true);
            }

            drawingContext.DrawGeometry(Fill, Border, streamGeometry1);
            drawingContext.DrawGeometry(Fill, Border, streamGeometry2);
            drawingContext.DrawLine(Border, stp.ToPoint(), sp.ToPoint());
        }
    }
}
