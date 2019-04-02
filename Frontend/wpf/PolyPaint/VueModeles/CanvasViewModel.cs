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
        public CanvasViewModel(string canvasId, string name, BitmapSource imagePreview, StrokeCollection strokes, string canvasVisibility, string canvasProtection, string canvasAutor)
        {
            CanvasId = canvasId;
            Name = name;
            ImagePreview = imagePreview;
            Strokes = strokes;
            CanvasVisibility = canvasVisibility;
            CanvasProtection = canvasProtection;
            CanvasAutor = canvasAutor;
        }
        public string CanvasId { get; set; }
        public string Name { get; set; }
        public BitmapSource ImagePreview { get; set; }
        public StrokeCollection Strokes { get; set; }
        public string CanvasVisibility { get; set; }
        public string CanvasProtection { get; set; }
        public string CanvasAutor { get; set; }
    }
}
