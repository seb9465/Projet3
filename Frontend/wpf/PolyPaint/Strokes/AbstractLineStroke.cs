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
        private bool FirstPointSnapped { get; set; }
        private bool SecondPointSnapped { get; set; }
        private Point NewFirstPoint { get; set; }
        private Point NewSecondPoint { get; set; }
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

        public AbstractLineStroke(StylusPointCollection stylusPoints, InkCanvas surfaceDessin, string from, string to, string couleurBordure, string couleurRemplissage, double thicc, bool isRelation, DashStyle dashStyle)
            : base(stylusPoints, surfaceDessin, couleurBordure, couleurRemplissage, thicc, dashStyle)
        {
            IsRelation = isRelation;
            BothAttached = false;
            LastElbowPosition = new Point((stylusPoints[0].X + stylusPoints[1].X) / 2, (stylusPoints[0].Y + stylusPoints[1].Y) / 2);
            Source = new FormattedText(from, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
            Destination = new FormattedText(to, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);
            Title = new FormattedText("", System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, new Typeface("Arial"), 12, Brushes.Black);

            Invalidated += (object sender, EventArgs e) =>
            {
                LastElbowPosition = new Point((StylusPoints[0].X + StylusPoints[1].X) / 2, (StylusPoints[0].Y + StylusPoints[1].Y) / 2);
            };
        }

        protected StylusPointCollection AttachToAnchors()
        {
            Point firstPoint = new Point(StylusPoints[0].X, StylusPoints[0].Y);
            Point secondPoint = new Point(StylusPoints[1].X, StylusPoints[1].Y);

            List<Anchor> anchors = new List<Anchor>();
            foreach (AbstractShapeStroke stroke in SurfaceDessin.Strokes.Where(x => x is AbstractShapeStroke))
            {
                anchors.AddRange(stroke.AnchorPoints);
            }

            if (anchors.Count > 0)
            {
                if (!FirstPointSnapped)
                {
                    var firstCloseVector = (Vector)anchors.OrderBy(x => Point.Subtract(x, firstPoint).Length).First();
                    var firstDistance = Vector.Subtract(firstCloseVector, (Vector)firstPoint).Length;
                    if (firstDistance < Config.MIN_DISTANCE_ANCHORS)
                    {
                        NewFirstPoint =  (Point)firstCloseVector;
                        FirstPointSnapped = true;
                    }
                    else
                    {
                        NewFirstPoint = StylusPoints[0].ToPoint();
                    }
                }

                if (!SecondPointSnapped)
                {
                    var secondCloseVector = (Vector)anchors.OrderBy(x => Point.Subtract(x, secondPoint).Length).First();
                    var secondDistance = Vector.Subtract(secondCloseVector, (Vector)secondPoint).Length;
                    if (secondDistance < Config.MIN_DISTANCE_ANCHORS)
                    {
                        NewSecondPoint = (Point)secondCloseVector;
                        SecondPointSnapped = true;
                    }
                    else
                    {
                        NewSecondPoint = StylusPoints[1].ToPoint();
                    }
                }

                BothAttached = FirstPointSnapped && SecondPointSnapped;
                return new StylusPointCollection(new Point[] { NewFirstPoint, NewSecondPoint });
            }
            else
            {
                BothAttached = false;
                return StylusPoints;
            }
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
