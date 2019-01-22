using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PolyPaint.Modeles
{
    class SaveableCanvas
    {
        public SaveableCanvas(string name, string base64Strokes)
        {
            Name = name;
            Base64Strokes = base64Strokes;
        }
        public string CanvasId { get; set; }
        public string Name { get; set; }
        public string Base64Strokes { get; set; }
    }
}
