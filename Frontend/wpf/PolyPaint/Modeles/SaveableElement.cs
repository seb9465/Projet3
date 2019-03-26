using System;
using System.Collections.Generic;
using System.Windows;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace PolyPaint.Modeles
{
    [Serializable]
    public class SaveableElement
    {
        public SaveableElement(string elementName, Point startingPoint, Point endPoint)
        {
            ElementName = elementName;
            StartingPoint = startingPoint;
            EndPoint = EndPoint;
        }
        public string ElementName { get; set; }
        public Point StartingPoint{ get; set; }
        public Point EndPoint { get; set; }
    }
}
