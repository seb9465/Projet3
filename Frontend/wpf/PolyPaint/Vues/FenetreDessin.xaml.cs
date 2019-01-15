using System;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Controls.Primitives;
using PolyPaint.VueModeles;
using System.Windows.Media.Imaging;
using System.IO;
using Microsoft.Win32;
using System.Windows.Ink;

namespace PolyPaint
{
    /// <summary>
    /// Logique d'interaction pour FenetreDessin.xaml
    /// </summary>
    public partial class FenetreDessin : Window
    {
        public FenetreDessin()
        {
            InitializeComponent();
            DataContext = new VueModele();
        }
        
        // Pour gérer les points de contrôles.
        private void GlisserCommence(object sender, DragStartedEventArgs e) => (sender as Thumb).Background = Brushes.Black;
        private void GlisserTermine(object sender, DragCompletedEventArgs e) => (sender as Thumb).Background = Brushes.White;
        private void GlisserMouvementRecu(object sender, DragDeltaEventArgs e)
        {
            String nom = (sender as Thumb).Name;
            if (nom == "horizontal" || nom == "diagonal") colonne.Width = new GridLength(Math.Max(32, colonne.Width.Value + e.HorizontalChange));
            if (nom == "vertical" || nom == "diagonal") ligne.Height = new GridLength(Math.Max(32, ligne.Height.Value + e.VerticalChange));
        }

        // Pour la gestion de l'affichage de position du pointeur.
        private void surfaceDessin_MouseLeave(object sender, MouseEventArgs e) => textBlockPosition.Text = "";
        private void surfaceDessin_MouseMove(object sender, MouseEventArgs e)
        {
            Point p = e.GetPosition(surfaceDessin);
            textBlockPosition.Text = Math.Round(p.X) + ", " + Math.Round(p.Y) + "px";
        }

        private void DupliquerSelection(object sender, RoutedEventArgs e)
        {          
            surfaceDessin.CopySelection();
            surfaceDessin.Paste();
        }

        private void SupprimerSelection(object sender, RoutedEventArgs e) => surfaceDessin.CutSelection();

        private void SaveImage(object sender, RoutedEventArgs e)
        {
            // Save Image PNG (Probably gonna be used in the gallery later).
            //{
            //    SaveFileDialog saveFileDialog = new SaveFileDialog();
            //    saveFileDialog.DefaultExt = ".png"; // Default file extension
            //    saveFileDialog.Filter = "Image (.png)|*.png"; // Filter files by extension

            //    // Show save file dialog box
            //    Nullable<bool> result = saveFileDialog.ShowDialog();

            //    // Get the dimensions of the ink control
            //    var size = new Size(surfaceDessin.ActualWidth, surfaceDessin.ActualHeight);
            //    surfaceDessin.Margin = new Thickness(0, 0, 0, 0);
            //    surfaceDessin.Measure(size);
            //    surfaceDessin.Arrange(new Rect(size));

            //    int margin = (int)surfaceDessin.Margin.Left;
            //    int width = (int)surfaceDessin.ActualWidth - margin;
            //    int height = (int)surfaceDessin.ActualHeight - margin;

            //    // Render ink to bitmap
            //    RenderTargetBitmap rtb =
            //    new RenderTargetBitmap(width, height, 96d, 96d, PixelFormats.Default);
            //    rtb.Render(surfaceDessin);

            //    // Save the ink to a memory stream
            //    BmpBitmapEncoder encoder = new BmpBitmapEncoder();
            //    encoder.Frames.Add(BitmapFrame.Create(rtb));
            //    byte[] bitmapBytes;
            //    using (MemoryStream ms = new MemoryStream())
            //    {
            //        encoder.Save(ms);
            //        // Get the bitmap bytes from the memory stream
            //        ms.Position = 0;
            //        bitmapBytes = ms.ToArray();
            //    }

            //    System.IO.File.WriteAllBytes(saveFileDialog.FileName, bitmapBytes);
            //}

            // Save Strokes to be able to reload it.
            {
                SaveFileDialog saveFileDialog = new SaveFileDialog();
                saveFileDialog.DefaultExt = ".stro"; // Default file extension
                saveFileDialog.Filter = "Strokes (.stro)|*.stro"; // Filter files by extension

                // Show save file dialog box
                Nullable<bool> result = saveFileDialog.ShowDialog();

                FileStream fs = null;

                try
                {
                    fs = new FileStream(saveFileDialog.FileName, FileMode.Create);
                    surfaceDessin.Strokes.Save(fs);
                }
                finally
                {
                    if (fs != null)
                    {
                        fs.Close();
                    }
                }

            }
        }

        private void LoadImage(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.DefaultExt = ".stro";
            openFileDialog.Filter = "Strokes (.stro)|*.stro"; // Filter files by extension

            // Show save file dialog box
            Nullable<bool> result = openFileDialog.ShowDialog();

            FileStream fs = null;

            if (!File.Exists(openFileDialog.FileName))
            {
                MessageBox.Show("The file you requested does not exist." +
                    " Save the StrokeCollection before loading it.");
                return;
            }

            try
            {
                fs = new FileStream(openFileDialog.FileName, FileMode.Open, FileAccess.Read);
                StrokeCollection strokes = new StrokeCollection(fs);
                surfaceDessin.Strokes = strokes;
            }
            finally
            {
                if (fs != null)
                {
                    fs.Close();
                }
            }
        }
    }
}
