using PolyPaint.Modeles;
using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Ink;
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
        public List<CanvasViewModel> Canvas { get; set; }
        public CanvasViewModel SelectedCanvas { get; set; }

        public Gallery(List<SaveableCanvas> strokes)
        {
            InitializeComponent();
            Canvas = CreateGalleryFromCloud(strokes);
            DataContext = Canvas;
            this.ShowDialog();
        }
        private static List<CanvasViewModel> CreateGalleryFromCloud(List<SaveableCanvas> strokes)
        {
            return ConvertStrokesToPNG(strokes);
        }

        private static List<CanvasViewModel> ConvertStrokesToPNG(List<SaveableCanvas> savedCanvas)
        {
            List<CanvasViewModel> canvas = new List<CanvasViewModel>();
            foreach (var item in savedCanvas)
            {
                var bytes = Convert.FromBase64String(item.Base64Strokes);
                var bitmapImage = GenerateImagePreview(bytes);
                var strokes = GenerateStrokesFromBytes(bytes);
                canvas.Add(new CanvasViewModel(item.CanvasId, item.Name, bitmapImage, strokes));
            }
            return canvas;
        }

        private static BitmapSource GenerateImagePreview(byte[] bytes)
        {
            return BitmapSource.Create(1, 1, 1, 1, PixelFormats.BlackWhite, null, new byte[] { 0 }, 1);
            //return (BitmapSource)new ImageSourceConverter().ConvertFrom(bytes);
        }

        private static StrokeCollection GenerateStrokesFromBytes(byte[] bytes)
        {
            StrokeCollection strokes;
            using (MemoryStream ms = new MemoryStream(bytes))
            {
                strokes = new System.Windows.Ink.StrokeCollection(ms);
                ms.Close();
            }
            return strokes;
        }

        private void OnSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            SelectedCanvas = (CanvasViewModel)ImagePreviews.SelectedItem;
            this.Close();
        }
    }
}
