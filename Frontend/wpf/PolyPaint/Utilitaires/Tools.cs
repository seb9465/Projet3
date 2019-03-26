using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
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
    }
}
