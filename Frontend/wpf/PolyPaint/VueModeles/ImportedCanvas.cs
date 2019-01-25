using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;

namespace PolyPaint.VueModeles
{
    public class ImportedCanvas
    {
        public ImportedCanvas(string canvasId, string name, BitmapSource imagePreview)
        {
            CanvasId = canvasId;
            Name = name;
            ImagePreview = imagePreview;

        }
        public string CanvasId { get; set; }
        public string Name { get; set; }
        public BitmapSource ImagePreview { get; set; }
    }
}
