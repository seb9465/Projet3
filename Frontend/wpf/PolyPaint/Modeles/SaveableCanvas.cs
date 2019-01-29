﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PolyPaint.Modeles
{
    public class SaveableCanvas
    {
        public SaveableCanvas(string name, string base64Strokes, string base64Image)
        {
            Name = name;
            Base64Strokes = base64Strokes;
            Base64Image = base64Image;
        }
        public string CanvasId { get; set; }
        public string Name { get; set; }
        public string Base64Strokes { get; set; }
        public string Base64Image { get; set; }
    }
}
