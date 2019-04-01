using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Windows;
using System.Windows.Markup;
using System.Windows.Media;
using System.Xml;

namespace PolyPaint.Utilitaires
{
    class Tools
    {
        public static T DeepCopy<T>(T element)
        {
            var xaml = XamlWriter.Save(element);
            var xamlString = new StringReader(xaml);
            var xmlTextReader = new XmlTextReader(xamlString);
            var deepCopyObject = (T)XamlReader.Load(xmlTextReader);
            return deepCopyObject;
        }

        public static ConcurrentDictionary<string, DashStyle> DashAssociations = new ConcurrentDictionary<string, DashStyle>(
            new Dictionary<string, DashStyle>()
            {
                        { "solid", DashStyles.Solid },
                        {"dash", DashStyles.Dash }
            }
        );

        public static Point RotatePoint(Point p1, Point p2, double angle)
        {
            double radians = ConvertToRadians(angle);
            double sin = Math.Sin(radians);
            double cos = Math.Cos(radians);

            // Translate point back to origin
            p1.X -= p2.X;
            p1.Y -= p2.Y;

            // Rotate point
            double xnew = p1.X * cos - p1.Y * sin;
            double ynew = p1.X * sin + p1.Y * cos;

            // Translate point back
            Point newPoint = new Point((int)xnew + p2.X, (int)ynew + p2.Y);
            return newPoint;
        }

        public static double ConvertToRadians(double angle)
        {
            return (Math.PI / 180) * angle;
        }
    }
}
