using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PolyPaint.Modeles
{
    public class SaveableCanvas
    {
        public SaveableCanvas(string canvasId, string name, string drawViewModels, byte[] image, string canvasVisibility, string canvasProtection, string canvasAutor)
        {
            CanvasId = canvasId;
            Name = name;
            DrawViewModels = drawViewModels;
            Image = image;
            CanvasVisibility = canvasVisibility;
            CanvasProtection = canvasProtection;
            CanvasAutor = canvasAutor;
        }
        public string CanvasId { get; set; }
        public string Name { get; set; }
        public string DrawViewModels { get; set; }
        public byte[] Image { get; set; }
        public string CanvasVisibility { get; set; }
        public string CanvasProtection { get; set; }
        public string CanvasAutor { get; set; }

    }
}
