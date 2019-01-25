using PolyPaint.Modeles;
using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for Gallery.xaml
    /// </summary>
    public partial class Gallery : Window
    {
        public List<ImportedCanvas> Canvas { get; set; }

        public Gallery(List<SaveableCanvas> strokes)
        {
            InitializeComponent();
            Canvas = CreateGalleryFromCloud(strokes);
            DataContext = Canvas;
            this.ShowDialog();
        }
        private static List<ImportedCanvas> CreateGalleryFromCloud(List<SaveableCanvas> strokes)
        {
            return ConvertStrokesToPNG(strokes);
        }

        private static List<ImportedCanvas> ConvertStrokesToPNG(List<SaveableCanvas> strokes)
        {
            List<ImportedCanvas> canvas = new List<ImportedCanvas>();
            foreach (var item in strokes)
            {
                var bytes = Convert.FromBase64String(item.Base64Strokes);
                var bitmap = (BitmapSource)new ImageSourceConverter().ConvertFrom(bytes);
                canvas.Add(new ImportedCanvas(item.CanvasId, item.Name, bitmap));
            }
            return canvas;
        }
    }
}
