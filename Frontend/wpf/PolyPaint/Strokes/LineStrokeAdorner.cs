﻿using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Ink;
using System.Linq;
using PolyPaint.Strokes;

public class LineStrokeAdorner : Adorner
{
    Thumb handle;
    VisualCollection visualChildren;
    Point center;
    Point dragPos;
    RotateTransform rotation;
    Rect strokeBounds = Rect.Empty;

    public LineStrokeAdorner(UIElement adornedElement)
        : base(adornedElement)
    {
        strokeBounds = AdornedStrokes.GetBounds();
        center = new Point(strokeBounds.X + strokeBounds.Width / 2,
                           strokeBounds.Y + strokeBounds.Height / 2);


        dragPos = AdornedStrokes.Count > 0 ? AdornedStroke.LastElbowPosition : center;

        visualChildren = new VisualCollection(this);
        handle = new Thumb
        {
            Cursor = Cursors.SizeAll,
            Width = 15,
            Height = 15,
            Background = Brushes.Blue
        };

        handle.DragDelta += new DragDeltaEventHandler(DragDelta);
        handle.DragCompleted += new DragCompletedEventHandler(DragCompleted);

        visualChildren.Add(handle);

        handle.Arrange(new Rect(strokeBounds.X + strokeBounds.Width / 2 - 7.5,
            strokeBounds.Y + strokeBounds.Height / 2 - 7.5,
            15, 15));
    }

    protected override Size ArrangeOverride(Size finalSize)
    {
        handle.Arrange(new Rect(dragPos.X - 7.5, dragPos.Y - 7.5, 15, 15));
        return finalSize;
    }

    void DragDelta(object sender, DragDeltaEventArgs e)
    {
        // FAUT PAS ENLEVER CA JE SAIS PAS PK
        rotation = new RotateTransform();
    }

    void DragCompleted(object sender, DragCompletedEventArgs e)
    {
        dragPos = Mouse.GetPosition(this);
        AdornedStroke.LastElbowPosition = dragPos;
        AdornedStroke.Redraw();
        InvalidateArrange();
    }

    private StrokeCollection AdornedStrokes
    {
        get
        {
            return new StrokeCollection(((InkCanvas)AdornedElement).GetSelectedStrokes().Where(x => x is AbstractLineStroke));
        }
    }

    private AbstractLineStroke AdornedStroke
    {
        get
        {
            return (AdornedStrokes.First() as AbstractLineStroke);
        }
    }

    protected override int VisualChildrenCount
    {
        get { return visualChildren.Count; }
    }

    protected override Visual GetVisualChild(int index)
    {
        return visualChildren[index];
    }
}