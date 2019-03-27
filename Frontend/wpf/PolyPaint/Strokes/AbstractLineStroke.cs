﻿using PolyPaint.Utilitaires;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractLineStroke : AbstractStroke
    {
        public bool IsRelation { get; set; }
        public bool BothAttached { get; set; }
        protected FormattedText Source { get; set; }
        public string SourceString
        {
            get { return Source.Text; }
            set
            {
                Source = new FormattedText(value, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
                ProprieteModifiee("Source");
                ProprieteModifiee();
            }
        }

        protected FormattedText Destination { get; set; }
        public string DestinationString
        {
            get { return Destination.Text; }
            set
            {
                Destination = new FormattedText(value, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
                ProprieteModifiee("Destination");
                ProprieteModifiee();
            }
        }

        public Point LastElbowPosition { get; set; }

        public AbstractLineStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string from, string to, string couleurBordure, string couleurRemplissage, double thicc, bool isRelation)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc)
        {
            IsRelation = isRelation;
            BothAttached = false;
            LastElbowPosition = new Point((stylusPoints[0].X + stylusPoints[1].X) / 2, (stylusPoints[0].Y + stylusPoints[1].Y) / 2);
            Source = new FormattedText(from, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
            Destination = new FormattedText(to, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);

            Invalidated += (object sender, EventArgs e) =>
            {
                LastElbowPosition = new Point((StylusPoints[0].X + StylusPoints[1].X) / 2, (StylusPoints[0].Y + StylusPoints[1].Y) / 2);
            };
        }

        private readonly double MIN_DISTANCE = 10;
        protected StylusPointCollection AttachToAnchors()
        {
            Point firstPoint = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            Point secondPoint = new Point(StylusPoints[1].X, StylusPoints[1].Y);

            List<Point> anchors = new List<Point>();
            foreach (AbstractShapeStroke stroke in SurfaceDessin.Strokes.Where(x => x is AbstractShapeStroke))
            {
                anchors.AddRange(stroke.AnchorPoints);
            }

            if (anchors.Count > 0)
            {
                var firstCloseVector = (Vector)anchors.OrderBy(x => Point.Subtract(x, firstPoint).Length).First();
                var firstDistance = Vector.Subtract(firstCloseVector, (Vector)firstPoint).Length;
                var newFirstPoint = firstDistance < MIN_DISTANCE ? (Point)firstCloseVector : StylusPoints[0].ToPoint();

                var secondCloseVector = (Vector)anchors.OrderBy(x => Point.Subtract(x, secondPoint).Length).First();
                var secondDistance = Vector.Subtract(secondCloseVector, (Vector)secondPoint).Length;
                var newSecondPoint = secondDistance < MIN_DISTANCE ? (Point)secondCloseVector : StylusPoints[1].ToPoint();

                BothAttached = firstDistance < MIN_DISTANCE && secondDistance < MIN_DISTANCE;
                return new StylusPointCollection(new Point[] { newFirstPoint, newSecondPoint });
            }
            else
            {
                BothAttached = false;
                return StylusPoints;
            }
        }
    }
}
