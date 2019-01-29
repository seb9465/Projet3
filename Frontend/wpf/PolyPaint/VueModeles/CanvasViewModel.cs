using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Ink;
using System.Windows.Media.Imaging;

namespace PolyPaint.VueModeles
{
    public class CanvasViewModel
    {
        public CanvasViewModel(string canvasId, string name, BitmapSource imagePreview, StrokeCollection strokes)
        {
            CanvasId = canvasId;
            Name = name;
            ImagePreview = imagePreview;
            Strokes = strokes;

        }
        public string CanvasId { get; set; }
        public string Name { get; set; }
        public BitmapSource ImagePreview { get; set; }
        public StrokeCollection Strokes { get; set; }
    }
}
