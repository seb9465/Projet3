using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Ink;
using System.Linq;
using PolyPaint.Strokes;
using PolyPaint.VueModeles;
using PolyPaint.Utilitaires;
using System;

public class LineStrokeAdorner : Adorner
{
    Thumb handle;
    VisualCollection visualChildren;
    Point center;
    Point dragPos;
    RotateTransform rotation;
    Rect strokeBounds = Rect.Empty;

    private readonly double ThumbRadius = 10;

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
            Width = 2*ThumbRadius,
            Height = 2 * ThumbRadius,
            Style = (Style)FindResource("TestRoundThumb")
        };

        handle.DragDelta += new DragDeltaEventHandler(DragDelta);
        handle.DragCompleted += new DragCompletedEventHandler(DragCompleted);

        visualChildren.Add(handle);

        handle.Arrange(new Rect(strokeBounds.X + strokeBounds.Width / 2 - ThumbRadius,
            strokeBounds.Y + strokeBounds.Height / 2 - ThumbRadius,
            2*ThumbRadius, 2*ThumbRadius));
    }

    protected override Size ArrangeOverride(Size finalSize)
    {
        handle.Arrange(new Rect(dragPos.X - ThumbRadius, dragPos.Y - ThumbRadius, 2 * ThumbRadius, 2 * ThumbRadius));
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
        ElbowChanging?.Invoke(this, new EventArgs());
        var spoints = AdornedStroke.StylusPoints;
        AdornedStroke.LastElbowPosition = dragPos;

        var affectedStrokes = AdornedStroke.TrySnap();
        if (!affectedStrokes.Select(x => (x as AbstractStroke).Guid).Contains(AdornedStroke.Guid)) affectedStrokes.Add(AdornedStroke);
        AdornedStroke.StylusPoints = new StylusPointCollection() { spoints[0], spoints[1], new StylusPoint(dragPos.X, dragPos.Y) };

        var drawViewModel = StrokeBuilder.GetDrawViewModelsFromStrokes(affectedStrokes);
        (AdornedStroke.SurfaceDessin.DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(drawViewModel);
        (AdornedStroke.SurfaceDessin.DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(StrokeBuilder.GetDrawViewModelsFromStrokes((AdornedElement as InkCanvas).GetSelectedStrokes()));
        ElbowChanged?.Invoke(this, new EventArgs());
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

    public event EventHandler ElbowChanged;
    public event EventHandler ElbowChanging;

    protected override Visual GetVisualChild(int index)
    {
        return visualChildren[index];
    }
}