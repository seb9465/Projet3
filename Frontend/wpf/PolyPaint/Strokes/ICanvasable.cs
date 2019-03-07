using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PolyPaint.Strokes
{
    interface ICanvasable
    {
        void AddToCanvas();
        void RemoveFromCanvas();
    }
}
