using PolyPaint.Utilitaires;
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

        public Point LastElbowPosition
        {
            get { return StylusPoints[0].ToPoint() + ElbowPosRelative; }
            set { }
        }
        public Vector ElbowPosRelative { get; set; }

        public AbstractLineStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string from, string to, string couleurBordure, string couleurRemplissage, double thicc, bool isRelation, DashStyle dashStyle)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            IsRelation = isRelation;
            BothAttached = false;
            ElbowPosRelative = new Vector((stylusPoints[1].X - stylusPoints[0].X) / 2, (stylusPoints[1].Y - stylusPoints[0].Y) / 2);
            Source = new FormattedText(from, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);
            Destination = new FormattedText(to, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);
            Title = new FormattedText("", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, Config.T_FACE, 12, Brushes.Black);

            Invalidated += (object sender, EventArgs e) =>
            {
                ElbowPosRelative = new Vector((StylusPoints[1].X - StylusPoints[0].X) / 2, (StylusPoints[1].Y - StylusPoints[0].Y) / 2);
            };
        }

        protected StylusPointCollection AttachToAnchors()
        {
            Point firstPoint = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            Point secondPoint = new Point(StylusPoints[1].X, StylusPoints[1].Y);

            var firstSnapped = false;
            var secondSnapped = false;
            var firstDistance = 0d;
            var secondDistance = 0d;
            var newFirstPoint = new Point();
            var newSecondPoint = new Point();
            foreach (AbstractShapeStroke stroke in SurfaceDessin.Strokes.Where(x => x is AbstractShapeStroke))
            {
                var anchors = stroke.AnchorPoints;

                if (anchors.Count > 0)
                {
                    if (!firstSnapped)
                    {
                        var firstCloseAnchor = anchors.OrderBy(x => Point.Subtract(x.Value, firstPoint).Length).First();
                        firstDistance = Vector.Subtract((Vector)firstCloseAnchor.Value, (Vector)firstPoint).Length;
                        if (firstDistance < Config.MIN_DISTANCE_ANCHORS)
                        {
                            newFirstPoint = firstCloseAnchor.Value;
                            if (IsDrawingDone)
                            {
                                stroke.OutConnections.AddOrUpdate(this, firstCloseAnchor.Key, (k, v) => firstCloseAnchor.Key);
                            }
                            firstSnapped = true;
                        }
                        else
                        {
                            newFirstPoint = StylusPoints[0].ToPoint();
                        } 
                    }

                    if (!secondSnapped)
                    {
                        var secondCloseAnchor = anchors.OrderBy(x => Point.Subtract(x.Value, secondPoint).Length).First();
                        secondDistance = Vector.Subtract((Vector)secondCloseAnchor.Value, (Vector)secondPoint).Length;
                        if (secondDistance < Config.MIN_DISTANCE_ANCHORS)
                        {
                            newSecondPoint = secondCloseAnchor.Value;
                            if (IsDrawingDone)
                            {
                                stroke.InConnections.AddOrUpdate(this, secondCloseAnchor.Key, (k, v) => secondCloseAnchor.Key);
                            }
                            secondSnapped = true;
                        }
                        else
                        {
                            newSecondPoint = StylusPoints[1].ToPoint();
                        } 
                    }
                }
            }

            if (firstDistance < Config.MIN_DISTANCE_ANCHORS || secondDistance < Config.MIN_DISTANCE_ANCHORS) Snapped = true;

            BothAttached = firstDistance < Config.MIN_DISTANCE_ANCHORS && secondDistance < Config.MIN_DISTANCE_ANCHORS;
            return new StylusPointCollection(new Point[] { newFirstPoint, newSecondPoint });
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
