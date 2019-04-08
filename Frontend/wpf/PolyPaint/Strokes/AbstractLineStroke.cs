using PolyPaint.Utilitaires;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public abstract class AbstractLineStroke : AbstractStroke
    {
        public bool IsRelation { get; set; }
        public bool BothAttached { get; set; }
        public bool Snapped { get; set; }
        protected FormattedText Source { get; set; }
        public string SourceString
        {
            get { return Source.Text; }
            set
            {
                Source = new FormattedText(value, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);
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
                Destination = new FormattedText(value, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);
                ProprieteModifiee("Destination");
                ProprieteModifiee();
            }
        }

        protected override FormattedText Title
        {
            get
            {
                base.Title.SetFontSize(12);
                return base.Title;
            }
            set
            {
                base.Title = value;
                base.Title.SetFontSize(12);
            }
        }

        public Point LastElbowPosition { get; set; }

        public AbstractLineStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string from, string to, string couleurBordure, string couleurRemplissage, double thicc, bool isRelation, DashStyle dashStyle)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            LastElbowPosition = new Point((StylusPoints[0].X + StylusPoints[1].X) / 2, (StylusPoints[0].Y + StylusPoints[1].Y) / 2);
            IsRelation = isRelation;
            BothAttached = false;
            Source = new FormattedText(from, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);
            Destination = new FormattedText(to, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);
            Title = new FormattedText("", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);

            Invalidated += (object sender, EventArgs e) =>
            {
                LastElbowPosition = new Point((StylusPoints[0].X + StylusPoints[1].X) / 2, (StylusPoints[0].Y + StylusPoints[1].Y) / 2);
            };
        }

        // For preview
        protected StylusPointCollection AttachToAnchors()
        {
            Point firstPoint = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            Point secondPoint = new Point(StylusPoints[1].X, StylusPoints[1].Y);

            List<Point> anchors = new List<Point>();
            foreach (AbstractShapeStroke stroke in SurfaceDessin.Strokes.Where(x => x is AbstractShapeStroke))
            {
                anchors.AddRange(stroke.AnchorPoints.Values);
            }

            if (anchors.Count > 0)
            {
                var firstCloseVector = (Vector)anchors.OrderBy(x => Point.Subtract(x, firstPoint).Length).First();
                var firstDistance = Vector.Subtract(firstCloseVector, (Vector)firstPoint).Length;
                var newFirstPoint = firstDistance < Config.MIN_DISTANCE_ANCHORS ? (Point)firstCloseVector : StylusPoints[0].ToPoint();

                var secondCloseVector = (Vector)anchors.OrderBy(x => Point.Subtract(x, secondPoint).Length).First();
                var secondDistance = Vector.Subtract(secondCloseVector, (Vector)secondPoint).Length;
                var newSecondPoint = secondDistance < Config.MIN_DISTANCE_ANCHORS ? (Point)secondCloseVector : StylusPoints[1].ToPoint();

                if (firstDistance < Config.MIN_DISTANCE_ANCHORS || secondDistance < Config.MIN_DISTANCE_ANCHORS) Snapped = true;

                BothAttached = firstDistance < Config.MIN_DISTANCE_ANCHORS && secondDistance < Config.MIN_DISTANCE_ANCHORS;
                return new StylusPointCollection(new Point[] { newFirstPoint, newSecondPoint });
            }
            else
            {
                BothAttached = false;
                return StylusPoints;
            }
        }

        public StrokeCollection TrySnap()
        {
            Point firstPoint = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            Point secondPoint = new Point(StylusPoints[1].X, StylusPoints[1].Y);

            StrokeCollection affected = new StrokeCollection();

            var firstDistance = 0d;
            var secondDistance = 0d;
            foreach (AbstractShapeStroke stroke in SurfaceDessin.Strokes.Where(x => x is AbstractShapeStroke))
            {
                var anchors = stroke.AnchorPoints;

                if (anchors.Count > 0)
                {
                    var firstCloseAnchor = anchors.OrderBy(x => Point.Subtract(x.Value, firstPoint).Length).First();
                    firstDistance = Vector.Subtract((Vector)firstCloseAnchor.Value, (Vector)firstPoint).Length;
                    if (firstDistance < Config.MIN_DISTANCE_ANCHORS)
                    {
                        StylusPoints[0] = new StylusPoint(firstCloseAnchor.Value.X, firstCloseAnchor.Value.Y);
                        stroke.OutConnections.AddOrUpdate(Guid, firstCloseAnchor.Key, (k, v) => firstCloseAnchor.Key);
                        affected.Add(stroke);
                    }

                    var secondCloseAnchor = anchors.OrderBy(x => Point.Subtract(x.Value, secondPoint).Length).First();
                    secondDistance = Vector.Subtract((Vector)secondCloseAnchor.Value, (Vector)secondPoint).Length;
                    if (secondDistance < Config.MIN_DISTANCE_ANCHORS)
                    {
                        StylusPoints[1] = new StylusPoint( secondCloseAnchor.Value.X , secondCloseAnchor.Value.Y);
                        stroke.InConnections.AddOrUpdate(Guid, secondCloseAnchor.Key, (k, v) => secondCloseAnchor.Key);
                        affected.Add(stroke);
                    }
                }
            }

            if (firstDistance < Config.MIN_DISTANCE_ANCHORS || secondDistance < Config.MIN_DISTANCE_ANCHORS) Snapped = true;

            BothAttached = firstDistance < Config.MIN_DISTANCE_ANCHORS && secondDistance < Config.MIN_DISTANCE_ANCHORS;
            return affected;
        }

        protected void DrawText(DrawingContext dc)
        {
            var firstAngle = Tools.ConvertToDegrees(Math.Atan2(LastElbowPosition.Y - StylusPoints[0].Y, LastElbowPosition.X - StylusPoints[0].X));
            var secondAngle = Tools.ConvertToDegrees(Math.Atan2(StylusPoints[1].Y - LastElbowPosition.Y, StylusPoints[1].X - LastElbowPosition.X));

            if (StylusPoints[0].X < StylusPoints[1].X)
            {
                var firstPoint = new Point(StylusPoints[0].X + 15, StylusPoints[0].Y - Source.Height);
                dc.PushTransform(new RotateTransform(firstAngle, StylusPoints[0].X, StylusPoints[0].Y));
                dc.DrawText(Source, firstPoint);
                dc.Pop();

                var secondPoint = new Point(StylusPoints[1].X - Destination.Width - 15, StylusPoints[1].Y - Destination.Height);
                dc.PushTransform(new RotateTransform(secondAngle, StylusPoints[1].X, StylusPoints[1].Y));
                dc.DrawText(Destination, secondPoint);
                dc.Pop();

                var elbowPoint = new Point(LastElbowPosition.X + 15, LastElbowPosition.Y - Title.Height);
                dc.PushTransform(new RotateTransform(secondAngle, LastElbowPosition.X, LastElbowPosition.Y));
                dc.DrawText(Title, elbowPoint);
                dc.Pop();
            }
            else
            {
                firstAngle += 180;
                secondAngle += 180;

                var secondPoint = new Point(StylusPoints[1].X + 15, StylusPoints[1].Y - Destination.Height);
                dc.PushTransform(new RotateTransform(secondAngle, StylusPoints[1].X, StylusPoints[1].Y));
                dc.DrawText(Destination, secondPoint);
                dc.Pop();

                var firstPoint = new Point(StylusPoints[0].X - Source.Width - 15, StylusPoints[0].Y - Source.Height);
                dc.PushTransform(new RotateTransform(firstAngle, StylusPoints[0].X, StylusPoints[0].Y));
                dc.DrawText(Source, firstPoint);
                dc.Pop();

                var elbowPoint = new Point(LastElbowPosition.X - Title.Width - 15, LastElbowPosition.Y - Title.Height);
                dc.PushTransform(new RotateTransform(secondAngle, LastElbowPosition.X, LastElbowPosition.Y));
                dc.DrawText(Title, elbowPoint);
                dc.Pop();
            }
        }
    }
}
