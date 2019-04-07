using PolyPaint.Common.Collaboration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Media;

namespace PolyPaint.Strokes
{
    public class OnlineSelectedAdorner : Adorner
    {

        private Pen _adornerBorderPen;
        private Pen _adornerPenBrush;
        private Brush _adornerFillBrush;
        private Pen _hatchPen;
        private Rect _strokesBounds;
        private List<Rect> _elementsBounds;

        private List<DrawViewModel> _strokes;
        private string _username;

        // The buffer around the outside of this element
        private const double BorderMargin = HatchBorderMargin + 2f;
        private const double HatchBorderMargin = 6f;

        // Constants for Resize handles.
        private const int CornerResizeHandleSize = 8;
        private const int MiddleResizeHandleSize = 6;
        private const double ResizeHandleTolerance = 3d;
        private const double LineThickness = 0.16;

        public OnlineSelectedAdorner(UIElement adornedElement, KeyValuePair<string, List<DrawViewModel>> pair)
            : base(adornedElement)
        {
            IsHitTestVisible = false;
            _username = pair.Key;
            _strokes = pair.Value;

            _adornerBorderPen = new Pen(Brushes.Black, 1.0);
            DoubleCollection dashes = new DoubleCollection();
            dashes.Add(4.5);
            dashes.Add(4.5);
            _adornerBorderPen.DashStyle = new DashStyle(dashes, 2.25);
            _adornerBorderPen.DashCap = PenLineCap.Flat;
            _adornerBorderPen.Freeze();

            _adornerPenBrush = new Pen(new SolidColorBrush(Color.FromRgb(132, 146, 222)), 1);
            _adornerPenBrush.Freeze();

            _adornerFillBrush = new SolidColorBrush(Color.FromArgb(100, 100, 100, 100));
            _adornerFillBrush.Freeze();

            // Create a hatch pen
            DrawingGroup hatchDG = new DrawingGroup();
            DrawingContext dc = null;

            try
            {
                dc = hatchDG.Open();

                dc.DrawRectangle(
                    Brushes.Transparent,
                    null,
                    new Rect(0.0, 0.0, 1f, 1f));

                Pen squareCapPen = new Pen(Brushes.Black, LineThickness);
                squareCapPen.StartLineCap = PenLineCap.Square;
                squareCapPen.EndLineCap = PenLineCap.Square;

                dc.DrawLine(squareCapPen,
                    new Point(1f, 0f), new Point(0f, 1f));
            }
            finally
            {
                if (dc != null)
                {
                    dc.Close();
                }
            }
            hatchDG.Freeze();

            DrawingBrush tileBrush = new DrawingBrush(hatchDG);
            tileBrush.TileMode = TileMode.Tile;
            tileBrush.Viewport = new Rect(0, 0, HatchBorderMargin, HatchBorderMargin);
            tileBrush.ViewportUnits = BrushMappingMode.Absolute;
            tileBrush.Freeze();

            _hatchPen = new Pen(tileBrush, HatchBorderMargin);
            _hatchPen.Freeze();

            _elementsBounds = new List<Rect>();
            _strokesBounds = Rect.Empty;
        }

        /// <summary>
        /// Update the selection wire frame.
        /// Called by
        ///         InkCanvasSelection.UpdateSelectionAdorner
        /// </summary>
        /// <param name="strokesBounds"></param>
        /// <param name="hatchBounds"></param>
        internal void UpdateSelectionWireFrame(Rect strokesBounds, List<Rect> hatchBounds)
        {
            bool isStrokeBoundsDifferent = false;
            bool isElementsBoundsDifferent = false;

            // Check if the strokes' bounds are changed.
            if (_strokesBounds != strokesBounds)
            {
                _strokesBounds = strokesBounds;
                isStrokeBoundsDifferent = true;
            }

            // Check if the elements' bounds are changed.
            int count = hatchBounds.Count;
            if (count != _elementsBounds.Count)
            {
                isElementsBoundsDifferent = true;
            }
            else
            {
                for (int i = 0; i < count; i++)
                {
                    if (_elementsBounds[i] != hatchBounds[i])
                    {
                        isElementsBoundsDifferent = true;
                        break;
                    }
                }
            }


            if (isStrokeBoundsDifferent || isElementsBoundsDifferent)
            {
                if (isElementsBoundsDifferent)
                {
                    _elementsBounds = hatchBounds;
                }

                // Invalidate our visual since the selection is changed.
                InvalidateVisual();
            }
        }

        /// <summary>
        /// OnRender
        /// </summary>
        /// <param name="drawingContext"></param>
        protected override void OnRender(DrawingContext drawingContext)
        {
            // Draw the background and hatch border around the elements
            DrawBackgound(drawingContext);

            // Draw the selection frame.
            Rect rectWireFrame = GetWireFrameRect();
            if (!rectWireFrame.IsEmpty)
            {
                // Draw the wire frame.
                drawingContext.DrawRectangle(_adornerFillBrush,
                    _adornerBorderPen,
                    rectWireFrame);

                var typeface = Config.T_FACE;
                var text = new FormattedText(_username, System.Globalization.CultureInfo.CurrentCulture, FlowDirection.LeftToRight, typeface, 12, new SolidColorBrush(Colors.White));
                drawingContext.DrawText(text, new Point(rectWireFrame.TopLeft.X + 10, rectWireFrame.TopLeft.Y + 10));
            }
        }

        /// <summary>
        /// Draw the hatches and the transparent area where isn't covering the elements.
        /// </summary>
        /// <param name="drawingContext"></param>
        private void DrawBackgound(DrawingContext drawingContext)
        {
            PathGeometry hatchGeometry = null;
            Geometry rectGeometry = null;

            int count = _elementsBounds.Count;
            if (count != 0)
            {
                // Create a union collection of the element regions.
                for (int i = 0; i < count; i++)
                {
                    Rect hatchRect = _elementsBounds[i];

                    if (hatchRect.IsEmpty)
                    {
                        continue;
                    }

                    hatchRect.Inflate(HatchBorderMargin / 2, HatchBorderMargin / 2);

                    if (hatchGeometry == null)
                    {
                        PathFigure path = new PathFigure();
                        path.StartPoint = new Point(hatchRect.Left, hatchRect.Top);

                        PathSegmentCollection segments = new PathSegmentCollection();

                        PathSegment line = new LineSegment(new Point(hatchRect.Right, hatchRect.Top), true);
                        line.Freeze();
                        segments.Add(line);

                        line = new LineSegment(new Point(hatchRect.Right, hatchRect.Bottom), true);
                        line.Freeze();
                        segments.Add(line);

                        line = new LineSegment(new Point(hatchRect.Left, hatchRect.Bottom), true);
                        line.Freeze();
                        segments.Add(line);

                        line = new LineSegment(new Point(hatchRect.Left, hatchRect.Top), true);
                        line.Freeze();
                        segments.Add(line);

                        segments.Freeze();
                        path.Segments = segments;

                        path.IsClosed = true;
                        path.Freeze();

                        hatchGeometry = new PathGeometry();
                        hatchGeometry.Figures.Add(path);
                    }
                    else
                    {
                        rectGeometry = new RectangleGeometry(hatchRect);
                        rectGeometry.Freeze();

                        hatchGeometry = Geometry.Combine(hatchGeometry, rectGeometry, GeometryCombineMode.Union, null);
                    }
                }
            }

            // Then, create a region which equals to "SelectionFrame - element1 bounds - element2 bounds - ..."
            GeometryGroup backgroundGeometry = new GeometryGroup();
            GeometryCollection geometryCollection = new GeometryCollection();

            // Add the entile rectanlge to the group.
            rectGeometry = new RectangleGeometry(new Rect(0, 0, RenderSize.Width, RenderSize.Height));
            rectGeometry.Freeze();
            geometryCollection.Add(rectGeometry);

            // Add the union of the element rectangles. Then the group will do oddeven operation.
            Geometry outlineGeometry = null;

            if (hatchGeometry != null)
            {
                hatchGeometry.Freeze();

                outlineGeometry = hatchGeometry.GetOutlinedPathGeometry();
                outlineGeometry.Freeze();
                if (count == 1 && _strokes.Count == 0)
                {
                    geometryCollection.Add(outlineGeometry);
                }
            }

            geometryCollection.Freeze();
            backgroundGeometry.Children = geometryCollection;
            backgroundGeometry.Freeze();

            // Then, draw the region which may contain holes so that the elements cannot be covered.
            // After that, the underneath elements can receive the messages.
            drawingContext.DrawGeometry(Brushes.Transparent, null, backgroundGeometry);

            // At last, draw the hatch borders
            if (outlineGeometry != null)
            {
                drawingContext.DrawGeometry(_adornerFillBrush, _hatchPen, outlineGeometry);
            }
        }

        /// <summary>
        /// Returns the wire frame bounds which crosses the center of the selection handles
        /// </summary>
        /// <returns></returns>
        private Rect GetWireFrameRect()
        {
            Rect frameRect = Rect.Empty;
            // trying to select bounds in all drawviewmodels

            Rect selectionRect = Rect.Empty;
            if (_strokes.Count > 0)
            {
                var xmin = _strokes.Min(stroke => stroke.StylusPoints[0].X < stroke.StylusPoints[1].X ? stroke.StylusPoints[0].X : stroke.StylusPoints[1].X);
                var ymin = _strokes.Min(stroke => stroke.StylusPoints[0].Y < stroke.StylusPoints[1].Y ? stroke.StylusPoints[0].Y : stroke.StylusPoints[1].Y);

                var xmax = _strokes.Max(stroke => stroke.StylusPoints[0].X > stroke.StylusPoints[1].X ? stroke.StylusPoints[0].X : stroke.StylusPoints[1].X);
                var ymax = _strokes.Max(stroke => stroke.StylusPoints[0].Y > stroke.StylusPoints[1].Y ? stroke.StylusPoints[0].Y : stroke.StylusPoints[1].Y);

                if (_strokes.Where(x => x.IsConnection()).Count() > 0)
                {
                    xmin = _strokes.Where(x => x.IsConnection()).Min(x => xmin < x.LastElbowPosition.X ? xmin : x.LastElbowPosition.X);
                    ymin = _strokes.Where(x => x.IsConnection()).Min(x => ymin < x.LastElbowPosition.Y ? ymin : x.LastElbowPosition.Y);
                    xmax = _strokes.Where(x => x.IsConnection()).Max(x => xmax > x.LastElbowPosition.X ? xmax : x.LastElbowPosition.X);
                    ymax = _strokes.Where(x => x.IsConnection()).Max(x => ymax > x.LastElbowPosition.Y ? ymax : x.LastElbowPosition.Y);
                }

                selectionRect = new Rect(new Point(xmin, ymin), new Point(xmax, ymax));
            }

            if (!selectionRect.IsEmpty)
            {
                frameRect = Rect.Inflate(selectionRect, BorderMargin, BorderMargin);
            }

            return frameRect;
        }
    }
}