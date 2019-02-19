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
using System.Net.Http;
using PolyPaint.Modeles;
using Newtonsoft.Json;
using System.Net.Http.Headers;
using System.Text;
using System.Collections.Generic;
using PolyPaint.Vues;
using PolyPaint.Structures;
using PolyPaint.Strokes;
using System.Windows.Controls;

namespace PolyPaint
{
    /// <summary>
    /// Logique d'interaction pour FenetreDessin.xaml
    /// </summary>
    public partial class FenetreDessin : Window
    {
        ChatWindow externalChatWindow;

        Stroke DrawingStroke = null;
        bool IsDrawing = false;
        Point currentPoint, mouseLeftDownPoint;
        public FenetreDessin()
        {
            InitializeComponent();
            var token = Application.Current.Properties["token"];
            DataContext = new VueModele();
            (DataContext as VueModele).ChatClient.Initialize((string)Application.Current.Properties["token"]);
            (DataContext as VueModele).ChatClient.MessageReceived += AddMessage;
            (DataContext as VueModele).ChatClient.SystemMessageReceived += AddSystemMessage;
            externalChatWindow = new ChatWindow(DataContext);

            Application.Current.Exit += OnClosing;
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

            // Select single UML option is not an existing InkCanvasEditingMode, so this extra verification
            // is required when moving the mouse in canvas.
            if ((DataContext as VueModele).OutilSelectionne == "lasso")
                surfaceDessin.EditingMode = InkCanvasEditingMode.Select;

            else if (surfaceDessin.GetSelectedStrokes().Count == 0)
                surfaceDessin.EditingMode = InkCanvasEditingMode.None;
        }

        private void DupliquerSelection(object sender, RoutedEventArgs e)
        {
            surfaceDessin.CopySelection();
            surfaceDessin.Paste();
        }

        private void SupprimerSelection(object sender, RoutedEventArgs e) => surfaceDessin.CutSelection();

        private void SaveImage(object sender, RoutedEventArgs e)
        {
            // Save Strokes on a file.
            {
                SaveFileDialog saveFileDialog = new SaveFileDialog
                {
                    DefaultExt = ".stro",
                    Filter = "Strokes (.stro)|*.stro"
                };

                // Show save file dialog box
                Nullable<bool> result = saveFileDialog.ShowDialog();

                FileStream fs = null;

                try
                {
                    fs = new FileStream(saveFileDialog.FileName, FileMode.Create);
                    surfaceDessin.Strokes.Save(fs);
                }
                catch
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
            // Load the strokes file.
            OpenFileDialog openFileDialog = new OpenFileDialog
            {
                DefaultExt = ".stro",
                Filter = "Strokes (.stro)|*.stro"
            };

            // Show save file dialog box
            Nullable<bool> result = openFileDialog.ShowDialog();

            FileStream fs = null;

            if (!File.Exists(openFileDialog.FileName))
            {
                MessageBox.Show("The file you requested does not exist." + " Save the StrokeCollection before loading it.");
                return;
            }

            try
            {
                // Put the strokes from the file onto the InkCanvas.
                fs = new FileStream(openFileDialog.FileName, FileMode.Open, FileAccess.Read);
                StrokeCollection importedStrokes = new StrokeCollection(fs);
                surfaceDessin.Strokes.Clear();
                surfaceDessin.Strokes.Add(importedStrokes);
            }
            catch
            {
                if (fs != null)
                {
                    fs.Close();
                }
            }
        }

        private async void SendToCloud(object sender, RoutedEventArgs e)
        {
            byte[] strokesBytes = GetBytesForStrokes();
            byte[] imageBytes = GetBytesForImage();
            string strokesToSend = Convert.ToBase64String(strokesBytes);
            string imageToSend = Convert.ToBase64String(imageBytes);
            SaveableCanvas canvas = new SaveableCanvas("NameNotImplementedYet", strokesToSend, imageToSend);

            string canvasJson = JsonConvert.SerializeObject(canvas);
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6Im9saXZpZXIubGF1em9uIiwibmFtZWlkIjoiMjY5MGYyMjAtN2JiYS00NDViLTgzYWEtMjIwZmVlMDczMTRiIiwiZmFtaWx5X25hbWUiOiJ1c2VyIiwibmJmIjoxNTUwNTkwMjgzLCJleHAiOjYxNTUwNTkwMjIzLCJpYXQiOjE1NTA1OTAyODMsImlzcyI6Imh0dHBzOi8vcG9seXBhaW50Lm1lIiwiYXVkIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUifQ.7zc5SqJNkJi7q8-SPzJ7Jbz1S5umsMszoJrxyBResVQ");
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                var content = new StringContent(canvasJson, Encoding.UTF8, "application/json");
                var response = await client.PostAsync("https://localhost:44300/api/user/canvas", content);
                var responseString = await response.Content.ReadAsStringAsync();
            }
        }

        private async void ImportFromCloud(object sender, RoutedEventArgs e)
        {
            List<SaveableCanvas> strokes;
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6Im9saXZpZXIubGF1em9uIiwibmFtZWlkIjoiMjY5MGYyMjAtN2JiYS00NDViLTgzYWEtMjIwZmVlMDczMTRiIiwiZmFtaWx5X25hbWUiOiJ1c2VyIiwibmJmIjoxNTUwNTkwMjgzLCJleHAiOjYxNTUwNTkwMjIzLCJpYXQiOjE1NTA1OTAyODMsImlzcyI6Imh0dHBzOi8vcG9seXBhaW50Lm1lIiwiYXVkIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUifQ.7zc5SqJNkJi7q8-SPzJ7Jbz1S5umsMszoJrxyBResVQ");
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                var response = await client.GetAsync("https://localhost:44300/api/user/canvas");
                var responseString = await response.Content.ReadAsStringAsync();
                strokes = JsonConvert.DeserializeObject<List<SaveableCanvas>>(responseString);
            }
            Gallery gallery = new Gallery(strokes, surfaceDessin);
            surfaceDessin.Strokes.Clear();
            surfaceDessin.Strokes.Add(gallery.SelectedCanvas.Strokes);
        }

        private byte[] GetBytesForStrokes()
        {
            MemoryStream ms = new MemoryStream();
            using (var memoryStream = new MemoryStream())
            {
                surfaceDessin.Strokes.Save(ms);
                return ms.ToArray();
            }
        }
        private byte[] GetBytesForImage()
        {
            // Get the dimensions of the ink canvas
            var size = new Size(surfaceDessin.ActualWidth, surfaceDessin.ActualHeight);
            surfaceDessin.Margin = new Thickness(0, 0, 0, 0);
            surfaceDessin.Measure(size);
            surfaceDessin.Arrange(new Rect(size));

            int margin = (int)surfaceDessin.Margin.Left;
            int width = (int)surfaceDessin.ActualWidth - margin;
            int height = (int)surfaceDessin.ActualHeight - margin;

            // Convert the strokes from the canvas to a bitmap
            RenderTargetBitmap rtb = new RenderTargetBitmap(width, height, 96d, 96d, PixelFormats.Default);
            rtb.Render(surfaceDessin);

            // Save the bitmap to a memory stream
            BmpBitmapEncoder encoder = new BmpBitmapEncoder();
            encoder.Frames.Add(BitmapFrame.Create(rtb));
            byte[] bitmapBytes;
            using (MemoryStream ms = new MemoryStream())
            {
                encoder.Save(ms);
                ms.Position = 0;
                bitmapBytes = ms.ToArray();
            }
            return bitmapBytes;
        }

        private void AddMessage(object sender, EventArgs args)
        {
            MessageArgs messArgs = args as MessageArgs;
            this.Dispatcher.Invoke(() =>
            {
                messagesList.Items.Add($"{messArgs.Timestamp} - {messArgs.Username}: {messArgs.Message}");
                messagesList.SelectedIndex = messagesList.Items.Count - 1;
                messagesList.ScrollIntoView(messagesList.SelectedItem);
            });
        }

        private void AddSystemMessage(object sender, EventArgs args)
        {
            MessageArgs messArgs = args as MessageArgs;
            this.Dispatcher.Invoke(() =>
            {
                messagesList.Items.Add(messArgs.Message);
                messagesList.SelectedIndex = messagesList.Items.Count - 1;
                messagesList.ScrollIntoView(messagesList.SelectedItem);
            });
        }

        private void chatButton_Click(object sender, RoutedEventArgs e)
        {
            externalChatWindow.Show();
            chat.Visibility = Visibility.Collapsed;
        }

        private void chatButtonSameWindow_Click(object sender, RoutedEventArgs e)
        {
            externalChatWindow.Close();
            chat.Visibility = Visibility.Visible;
        }

        private void sendButton_Click(object sender, RoutedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(messageTextBox.Text))
            {
                (DataContext as VueModele).ChatClient.SendMessage(messageTextBox.Text);
            }
            messageTextBox.Text = String.Empty;
            messageTextBox.Focus();
        }


        private void enterKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                sendButton_Click(sender, e);
            }
        }

        private void OnClosing(object sender, EventArgs e)
        {
            try
            {
                using (var client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                    System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                    client.GetAsync("https://localhost:44300/api/user/logout").Wait();
                }
            }
            catch { }
        }
        private void InkCanvas_LeftMouseDown(object sender, MouseButtonEventArgs e)
        {
            mouseLeftDownPoint = e.GetPosition((IInputElement)sender);

            if ((DataContext as VueModele).OutilSelectionne == "select")
            {
                var all = surfaceDessin.EditingMode;
                StrokeCollection strokes = surfaceDessin.Strokes;
                // We travel the StrokeCollection inversely to select the first plan item first
                // if some items overlap.
                StrokeCollection strokeToSelect = new StrokeCollection();
                for (int i = strokes.Count - 1; i >= 0; i--)
                {
                    Rect box = strokes[i].GetBounds();
                    if (mouseLeftDownPoint.X >= box.Left && mouseLeftDownPoint.X <= box.Right &&
                        mouseLeftDownPoint.Y <= box.Bottom && mouseLeftDownPoint.Y >= box.Top)
                    {
                        strokeToSelect.Add(strokes[i]);
                        surfaceDessin.Select(strokeToSelect);
                        break;
                    }
                }
            }

            IsDrawing = true;
        }
        private void InkCanvas_LeftMouseMove(object sender, MouseEventArgs e)
        {
            if (IsDrawing)
            {
                currentPoint = e.GetPosition((IInputElement)sender);
                StylusPointCollection pts = new StylusPointCollection();

                pts.Add(new StylusPoint(mouseLeftDownPoint.X, mouseLeftDownPoint.Y));
                pts.Add(new StylusPoint(currentPoint.X, currentPoint.Y));

                if (DrawingStroke != null)
                    surfaceDessin.Strokes.Remove(DrawingStroke);

                switch ((DataContext as VueModele).OutilSelectionne)
                {
                    case "rectangle":
                        DrawingStroke = new RectangleStroke(pts);
                        DrawingStroke.DrawingAttributes.Color = Colors.LightBlue;
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                    case "rounded_rectangle":
                        DrawingStroke = new RoundedRectangleStroke(pts);
                        DrawingStroke.DrawingAttributes.Color = Colors.Red;
                        surfaceDessin.Strokes.Add(DrawingStroke);
                        break;
                }
            }
        }

        private void InkCanvas_LeftMouseUp(object sender, MouseButtonEventArgs e)
        {
            if (DrawingStroke != null && (DataContext as VueModele).OutilSelectionne == "rectangle" 
                                      || (DataContext as VueModele).OutilSelectionne == "rounded_rectangle")
            {
                surfaceDessin.Strokes.Remove(DrawingStroke);
                surfaceDessin.Strokes.Add(DrawingStroke.Clone());
            }
            IsDrawing = false;
        }
    }
}
