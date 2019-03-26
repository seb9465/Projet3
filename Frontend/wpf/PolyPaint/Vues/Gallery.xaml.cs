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
        private ImageProtection imageProtection;
        private string username;

        public Gallery(List<SaveableCanvas> strokes, InkCanvas drawingSurface)
        {
            InitializeComponent();
            Canvas = ConvertStrokesToPNG(strokes, drawingSurface);
            DataContext = Canvas;
            username = Application.Current.Properties["username"].ToString();
            usernameLabel.Content = username;
            this.ShowDialog();
        }

        private List<CanvasViewModel> ConvertStrokesToPNG(List<SaveableCanvas> savedCanvas, InkCanvas drawingSurface)
        {
            List<CanvasViewModel> canvas = new List<CanvasViewModel>();
            if(savedCanvas != null)
            {
                foreach (var item in savedCanvas)
                {
                    var bitmapImage = (BitmapSource)new ImageSourceConverter().ConvertFrom(Convert.FromBase64String(item.Base64Image));
                    var strokes = GenerateStrokesFromBytes(Convert.FromBase64String(item.Base64Strokes));
                    canvas.Add(new CanvasViewModel(item.CanvasId, item.Name, bitmapImage, strokes, item.CanvasVisibility, item.CanvasProtection));
                }
                
            }
            return canvas;
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
            if (SelectedCanvas.CanvasProtection != "")
            {
                imageProtection = new ImageProtection();
                if(imageProtection.PasswordEntered == SelectedCanvas.CanvasProtection)
                {
                    this.Close();
                } else
                {
                    SelectedCanvas = null;
                    MessageBox.Show("Wrong password");
                }
            } else
            {
            this.Close();
            }
        }

        private void GoBack_Click(object sender, RoutedEventArgs e)
        {
            MenuProfile menuProfile = new MenuProfile();
            Application.Current.MainWindow = menuProfile;
            Close();
            menuProfile.Show();
        }
    }
}
