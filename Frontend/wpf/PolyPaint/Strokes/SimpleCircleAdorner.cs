//using System;
//using System.Windows;
//using System.Windows.Controls;
//using System.Windows.Controls.Primitives;
//using System.Windows.Documents;
//using System.Windows.Input;
//using System.Windows.Media;
//using System.Windows.Ink;
//using System.Collections.ObjectModel;
//using System.Linq;
//using PolyPaint.Strokes;
//using System.Collections.Generic;

//public class RotatingStrokesAdorner : Adorner
//{
//    Thumb handle;

//    VisualCollection visualChildren;

//    Point center;
//    Point dragPos = new Point();

//    const int HANDLEMARGIN = 10;

//    // The bounds of the Strokes;
//    Rect strokeBounds = Rect.Empty;

//    public RotatingStrokesAdorner(UIElement adornedElement)
//        : base(adornedElement)
//    {
//        visualChildren = new VisualCollection(this);

//        handle = new Thumb();
//        handle.Cursor = Cursors.SizeAll;
//        handle.Width = 15;
//        handle.Height = 15;
//        handle.Background = Brushes.Blue;

//        handle.DragDelta += new DragDeltaEventHandler(dragDelta);
//        handle.DragCompleted += new DragCompletedEventHandler(dragCompleted);

//        visualChildren.Add(handle);
//        visualChildren = new VisualCollection(this);

//        strokeBounds = AdornedStrokes.GetBounds();
//    }

//    protected override Size ArrangeOverride(Size finalSize)
//    {
//        if (strokeBounds.IsEmpty)
//        {
//            return finalSize;
//        }

//        center = new Point(strokeBounds.X + strokeBounds.Width / 2,
//                           strokeBounds.Y + strokeBounds.Height / 2);

//        // The rectangle that determines the position of the Thumb.
//        Rect handleRect = new Rect(strokeBounds.X,
//                              strokeBounds.Y - (strokeBounds.Height / 2 +
//                                                HANDLEMARGIN),
//                              strokeBounds.Width, strokeBounds.Height);


//        // Draws the thumb and the rectangle around the strokes.
//        handle.Arrange(handleRect);
//        return finalSize;
//    }

//    /// <summary>
//    /// Rotates the rectangle representing the
//    /// strokes' bounds as the user drags the
//    /// Thumb.
//    /// </summary>
//    void dragDelta(object sender, DragDeltaEventArgs e)
//    {
//        dragPos = Mouse.GetPosition(this);
//    }

//    /// <summary>
//    /// Rotates the strokes to the same angle as outline.
//    /// </summary>
//    void dragCompleted(object sender, DragCompletedEventArgs e)
//    {
//        // Rotate the strokes to match the new angle.
//        ((AbstractLineStroke)AdornedStrokes.Where(x => x is AbstractLineStroke).First()).AddElbow(dragPos);

//        // Redraw rotateHandle.
//        InvalidateArrange();
//    }

//    /// <summary>
//    /// Gets the strokes of the adorned element 
//    /// (in this case, an InkPresenter).
//    /// </summary>
//    private StrokeCollection AdornedStrokes
//    {
//        get
//        {
//            return new StrokeCollection(((InkCanvas)AdornedElement).GetSelectedStrokes().Where(x => x is AbstractLineStroke));
//        }
//    }

//    // Override the VisualChildrenCount and 
//    // GetVisualChild properties to interface with 
//    // the adorner's visual collection.
//    protected override int VisualChildrenCount
//    {
//        get { return visualChildren.Count; }
//    }

//    protected override Visual GetVisualChild(int index)
//    {
//        return visualChildren[index];
//    }
//}
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Shapes;
using System.Windows.Ink;
using System.Linq;
using PolyPaint.Strokes;

public class RotatingStrokesAdorner : Adorner
{
    Thumb handle;

    VisualCollection visualChildren;
    Point center;
    Point dragPos;

    RotateTransform rotation;

    const int HANDLEMARGIN = 10;

    // The bounds of the Strokes;
    Rect strokeBounds = Rect.Empty;

    public RotatingStrokesAdorner(UIElement adornedElement)
        : base(adornedElement)
    {
        strokeBounds = AdornedStrokes.GetBounds();
        center = new Point(strokeBounds.X + strokeBounds.Width / 2,
                           strokeBounds.Y + strokeBounds.Height / 2);


        dragPos = AdornedStrokes.Count > 0 ? AdornedStroke.LastElbowPosition : center;

        visualChildren = new VisualCollection(this);
        handle = new Thumb();
        handle.Cursor = Cursors.SizeAll;
        handle.Width = 15;
        handle.Height = 15;
        handle.Background = Brushes.Blue;

        handle.DragDelta += new DragDeltaEventHandler(dragDelta);
        handle.DragCompleted += new DragCompletedEventHandler(dragCompleted);

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

    void dragDelta(object sender, DragDeltaEventArgs e)
    {
        // FAUT PAS ENLEVER CA JE SAIS PAS PK
        rotation = new RotateTransform();
    }

    void dragCompleted(object sender, DragCompletedEventArgs e)
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