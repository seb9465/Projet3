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
using PolyPaint.Chat;
using Microsoft.AspNetCore.SignalR.Client;

namespace PolyPaint
{
    /// <summary>
    /// Logique d'interaction pour FenetreDessin.xaml
    /// </summary>
    public partial class FenetreDessin : Window
    {
        public ChatClient ChatClient { get; set; }
        public FenetreDessin()
        {
            InitializeComponent();
            DataContext = new VueModele();
            ChatClient = new ChatClient();
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
            // Save Image PNG
            // This part is commented right now because it has no use,
            // but we will probably use it for the gallery later in the project.
            //{
            //    SaveFileDialog saveFileDialog = new SaveFileDialog
            //    {
            //        DefaultExt = ".png",
            //        Filter = "Image (.png)|*.png"
            //    };

            //    // Show save file dialog box
            //    Nullable<bool> result = saveFileDialog.ShowDialog();

            //    byte[] bitmapBytes = GetBytesFromCanvas();
            //    System.IO.File.WriteAllBytes(saveFileDialog.FileName, bitmapBytes);
            //}

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
            byte[] bitmapBytes = GetBytesFromCanvas();
            string strokesToSend = Convert.ToBase64String(bitmapBytes);
            SaveableCanvas canvas = new SaveableCanvas("NameNotImplementedYet", strokesToSend);

            string canvasJson = JsonConvert.SerializeObject(canvas);
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IkhvbWUiLCJuYW1laWQiOiI4MzBkYmI4NC1jMzYzLTQwZTYtYjdjMC03ZmM0ZWM5YmUzNDAiLCJuYmYiOjE1NDgxOTE5NDgsImV4cCI6NjE1NDgxOTE4ODgsImlhdCI6MTU0ODE5MTk0OCwiaXNzIjoiMTAuMjAwLjI3LjE2OjUwMDEiLCJhdWQiOiIxMC4yMDAuMjcuMTY6NTAwMSJ9.udDi-4deN17QsbeG72Jm8j-CAmIxzP4Pg3eQyV2KG3Q");
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                var content = new StringContent(canvasJson, Encoding.UTF8, "application/json");
                var response = await client.PostAsync("http://localhost:4000/api/user/canvas", content);
                var responseString = await response.Content.ReadAsStringAsync();
            }
        }

        private async void ImportFromCloud(object sender, RoutedEventArgs e)
        {
            List<SaveableCanvas> strokes;
            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IkhvbWUiLCJuYW1laWQiOiI4MzBkYmI4NC1jMzYzLTQwZTYtYjdjMC03ZmM0ZWM5YmUzNDAiLCJuYmYiOjE1NDgxOTE5NDgsImV4cCI6NjE1NDgxOTE4ODgsImlhdCI6MTU0ODE5MTk0OCwiaXNzIjoiMTAuMjAwLjI3LjE2OjUwMDEiLCJhdWQiOiIxMC4yMDAuMjcuMTY6NTAwMSJ9.udDi-4deN17QsbeG72Jm8j-CAmIxzP4Pg3eQyV2KG3Q");
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                var response = await client.GetAsync("http://localhost:4000/api/user/canvas");
                var responseString = await response.Content.ReadAsStringAsync();
                strokes = JsonConvert.DeserializeObject<List<SaveableCanvas>>(responseString);
            }
            GalleryGenerator.CreateGalleryFromCloud(strokes);
        }

        private byte[] GetBytesFromCanvas()
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
        private async void chatButton_Click(object sender, RoutedEventArgs e)
        {
            PolyPaint.Vues.ChatWindow w2 = new PolyPaint.Vues.ChatWindow();
            w2.Show();
            chat.Visibility = Visibility.Collapsed;
        }

        private async void chatButtonSameWindow_Click(object sender, RoutedEventArgs e)
        {
            chat.Visibility = Visibility.Visible;
        }

        private async void connectButtonn_Click(object sender, RoutedEventArgs e)
        {
            ChatClient.connection.On<string, string>("ReceiveMessage", (username, message) =>
            {
                this.Dispatcher.Invoke(() =>
                {
                    var newMessage = $"{username}: {message}";
                    messagesList.Items.Add(newMessage);
                });
            });

            try
            {
                await ChatClient.connection.StartAsync();
                await ChatClient.connection.InvokeAsync("ConnectToGroup",
                    groupTextBox.Text);
                messagesList.Items.Add("Connection started");
                connectButtonn.IsEnabled = false;
                sendButtonn.IsEnabled = true;
            }
            catch (Exception ex)
            {
                messagesList.Items.Add(ex.Message);
            }
        }

        private async void sendButtonn_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                await ChatClient.connection.InvokeAsync("SendMessage",
                    messageTextBox.Text);
            }
            catch (Exception ex)
            {
                messagesList.Items.Add(ex.Message);
            }
        }
    }
}
