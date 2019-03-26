using MaterialDesignThemes.Wpf;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Win32;
using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Modeles;
using PolyPaint.Strokes;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using PolyPaint.Vues;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;

namespace PolyPaint
{
    /// <summary>
    /// Logique d'interaction pour FenetreDessin.xaml
    /// </summary>
    public partial class FenetreDessin : Window
    {
        private StrokeBuilder rebuilder = new StrokeBuilder();
        private AdornerLayer adornerLayer;
        private LineStrokeAdorner adorner;

        private ChatWindow externalChatWindow;
        private MediaPlayer mediaPlayer = new MediaPlayer();
        private InkCanvasEventManager icEventManager = new InkCanvasEventManager();
        private bool IsDrawing = false;
        private Point currentPoint, mouseLeftDownPoint;
        private HubConnection Connection;
        public event EventHandler MessageReceived;
        private string username;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }

        public FenetreDessin(ViewStateEnum viewState)
        {
            InitializeComponent();
            _viewState = viewState;
            DataContext = new VueModele(viewState);

            (DataContext as VueModele).CollaborationClient.Initialize((string)Application.Current.Properties["token"]);
            (DataContext as VueModele).CollaborationClient.DrawReceived += ReceiveDraw;
            (DataContext as VueModele).CollaborationClient.SelectReceived += ReceiveSelect;
            (DataContext as VueModele).CollaborationClient.DuplicateReceived += ReceiveDuplicate;
            (DataContext as VueModele).CollaborationClient.DeleteReceived += ReceiveDelete;
            (DataContext as VueModele).CollaborationClient.ResetReceived += ReceiveReset;

            DispatcherTimer dispatcherTimer = new System.Windows.Threading.DispatcherTimer();
            dispatcherTimer.Tick += new EventHandler(SaveImage);
            dispatcherTimer.Interval = new TimeSpan(0, 1, 0);
            dispatcherTimer.Start();
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

        private async void DupliquerSelection(object sender, RoutedEventArgs e)
        {
            await (DataContext as VueModele).CollaborationClient.CollaborativeDuplicateAsync();

            surfaceDessin.CopySelection();
            surfaceDessin.Paste();
        }

        private async void SupprimerSelection(object sender, RoutedEventArgs e)
        {
            await (DataContext as VueModele).CollaborationClient.CollaborativeDeleteAsync();
            surfaceDessin.CutSelection();

        }
        private void SaveImage(object sender, EventArgs e)
        {
            // Save in temporary folder
            string filePath = Path.Combine(Path.GetTempPath(), "POLYPAINT_" + DateTime.Now.ToFileTime() + ".json");

            if (surfaceDessin.Strokes.Count > 0)
            {
                // Change strokes into DrawViewModels
                List<DrawViewModel> strokes = rebuilder.GetDrawViewModelsFromStrokes(surfaceDessin.Strokes);

                //Serialize our "strokes"
                FileStream fs = null;
                fs = new FileStream(filePath, FileMode.Create);
                var jsons = JsonConvert.SerializeObject(strokes);
                fs.Write(Encoding.UTF8.GetBytes(jsons), 0, Encoding.UTF8.GetByteCount(jsons));
            }
        }

        private void LoadImage(object sender, RoutedEventArgs e)
        {
            // Load the strokes file.
            OpenFileDialog openFileDialog = new OpenFileDialog
            {
                DefaultExt = ".json",
                Filter = "JSON (.json)|*.json"
            };

            // Show save file dialog box
            Nullable<bool> result = openFileDialog.ShowDialog();

            // Deserialize it
            FileStream fs = null;
            fs = new FileStream(openFileDialog.FileName, FileMode.Open, FileAccess.Read);
            byte[] jsons = new byte[fs.Length];
            fs.Read(jsons, 0, (int)fs.Length);

            List<DrawViewModel> customStrokes = JsonConvert.DeserializeObject<List<DrawViewModel>>(Encoding.UTF8.GetString(jsons));

            // Rebuild the strokes
            rebuilder.BuildStrokesFromDrawViewModels(customStrokes, surfaceDessin);
        }

        private async void SendToCloud(object sender, RoutedEventArgs e)
        {

            UploadToCloud uploadToCloud = new UploadToCloud();
            byte[] strokesBytes = GetBytesForStrokes();
            byte[] imageBytes = GetBytesForImage();
            string strokesToSend = Convert.ToBase64String(strokesBytes);
            string imageToSend = Convert.ToBase64String(imageBytes);
            string CanvasName = uploadToCloud.CanvasName;
            string CanvasVisibility = uploadToCloud.CanvasVisibility;
            SaveableCanvas canvas = new SaveableCanvas(CanvasName, strokesToSend, imageToSend, CanvasVisibility);

            string canvasJson = JsonConvert.SerializeObject(canvas);
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6Im9saXZpZXIubGF1em9uIiwibmFtZWlkIjoiMjY5MGYyMjAtN2JiYS00NDViLTgzYWEtMjIwZmVlMDczMTRiIiwiZmFtaWx5X25hbWUiOiJ1c2VyIiwibmJmIjoxNTUwNTkwMjgzLCJleHAiOjYxNTUwNTkwMjIzLCJpYXQiOjE1NTA1OTAyODMsImlzcyI6Imh0dHBzOi8vcG9seXBhaW50Lm1lIiwiYXVkIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUifQ.7zc5SqJNkJi7q8-SPzJ7Jbz1S5umsMszoJrxyBResVQ");
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                StringContent content = new StringContent(canvasJson, Encoding.UTF8, "application/json");
                HttpResponseMessage response = await client.PostAsync($"{Config.URL}/api/user/canvas", content);
                string responseString = await response.Content.ReadAsStringAsync();
            }

        }

        private async void ImportFromCloud(object sender, RoutedEventArgs e)
        {
            progressBar.Visibility = Visibility.Visible;
            List<SaveableCanvas> strokes;
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6Im9saXZpZXIubGF1em9uIiwibmFtZWlkIjoiMjY5MGYyMjAtN2JiYS00NDViLTgzYWEtMjIwZmVlMDczMTRiIiwiZmFtaWx5X25hbWUiOiJ1c2VyIiwibmJmIjoxNTUwNTkwMjgzLCJleHAiOjYxNTUwNTkwMjIzLCJpYXQiOjE1NTA1OTAyODMsImlzcyI6Imh0dHBzOi8vcG9seXBhaW50Lm1lIiwiYXVkIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUifQ.7zc5SqJNkJi7q8-SPzJ7Jbz1S5umsMszoJrxyBResVQ");
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/canvas");
                string responseString = await response.Content.ReadAsStringAsync();
                strokes = JsonConvert.DeserializeObject<List<SaveableCanvas>>(responseString);
            }
            progressBar.Visibility = Visibility.Collapsed;
            Gallery gallery = new Gallery(strokes, surfaceDessin);

            surfaceDessin.Strokes.Clear();
            surfaceDessin.Strokes.Add(gallery.SelectedCanvas.Strokes);
        }

        private byte[] GetBytesForStrokes()
        {
            MemoryStream ms = new MemoryStream();
            using (MemoryStream memoryStream = new MemoryStream())
            {
                surfaceDessin.Strokes.Save(ms);
                return ms.ToArray();
            }
        }
        private byte[] GetBytesForImage()
        {
            // Get the dimensions of the ink canvas
            Size size = new Size(surfaceDessin.ActualWidth, surfaceDessin.ActualHeight);
            surfaceDessin.Measure(new Size((int)surfaceDessin.ActualWidth, (int)surfaceDessin.ActualHeight));

            int margin = (int)surfaceDessin.Margin.Left;
            int width = (int)surfaceDessin.ActualWidth + 2 * margin;
            int height = (int)surfaceDessin.ActualHeight + 2 * margin;

            // Convert the strokes from the canvas to a bitmap
            RenderTargetBitmap rtb = new RenderTargetBitmap(width, height, 96d, 96d, PixelFormats.Pbgra32);
            rtb.Render(surfaceDessin);

            // Save the bitmap to a memory stream
            PngBitmapEncoder encoder = new PngBitmapEncoder();
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

        private void AddRoom(object sender, DialogClosingEventArgs eventArgs)
        {
            if (!Equals(eventArgs.Parameter, true)) return;

            if (!string.IsNullOrWhiteSpace(roomTextBox.Text))
            {
                (DataContext as VueModele).ChatClient.CreateChannel(roomTextBox.Text.Trim());
            }
            clearRoomName(sender, eventArgs);
        }

        private void clearRoomName(object sender, RoutedEventArgs e)
        {
            roomTextBox.Text = "";
        }
        private void ScrollDown(object sender, MessageArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                messagesList.SelectedIndex = messagesList.Items.Count - 1;
                messagesList.ScrollIntoView(messagesList.SelectedItem);
            });
        }
        private void chatButton_Click(object sender, RoutedEventArgs e)
        {
            externalChatWindow.Show();
            chatWrapper.Visibility = Visibility.Collapsed;
            ScrollDown(null, null);
        }

        private void sendButton_Click(object sender, RoutedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(messageTextBox.Text))
            {
                (DataContext as VueModele).ChatClient.SendMessage(messageTextBox.Text, (DataContext as VueModele).CurrentRoom);
            }
            mediaPlayer.Open(new Uri("SoundEffects//send.mp3", UriKind.Relative));
            mediaPlayer.Volume = 100;
            mediaPlayer.Play();
            messageTextBox.Text = String.Empty;
            messageTextBox.Focus();
        }


        private void EnterKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                if (sendButton.IsEnabled)
                {
                    sendButton_Click(sender, e);
                }
            }
        }

        private void OnClosing(object sender, EventArgs e)
        {
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                    System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                    client.GetAsync($"{Config.URL}/api/user/logout").Wait();
                }
            }
            catch { }
        }


        private async void InkCanvas_LeftMouseDown(object sender, MouseButtonEventArgs e)
        {
            mouseLeftDownPoint = e.GetPosition((IInputElement)sender);

            if ((DataContext as VueModele).OutilSelectionne == "select")
            {
                SelectViewModel selectViewModel = new SelectViewModel
                {
                    MouseLeftDownPointX = mouseLeftDownPoint.X,
                    MouseLeftDownPointY = mouseLeftDownPoint.Y,
                    Owner = username,
                };
                await (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(selectViewModel);

                (DataContext as VueModele).SelectItemOffline(surfaceDessin, mouseLeftDownPoint);
            }
            else
            {
                IsDrawing = true;
            }
        }
        private void InkCanvas_LeftMouseMove(object sender, MouseEventArgs e)
        {
            currentPoint = e.GetPosition((IInputElement)sender);
            if (IsDrawing)
            {
                icEventManager.DrawShape(surfaceDessin, (DataContext as VueModele), currentPoint, mouseLeftDownPoint);
            }
        }

        private async void InkCanvas_LeftMouseUp(object sender, MouseButtonEventArgs e)
        {
            if ((DataContext as VueModele).OutilSelectionne == "") return;
            if (icEventManager.DrawingStroke != null)
            {
                StrokeCollection alloA = new StrokeCollection
                {
                    icEventManager.DrawingStroke
                };
                List<DrawViewModel> allo = rebuilder.GetDrawViewModelsFromStrokes(alloA);
                await (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(allo[0]);
            }
            icEventManager.EndDraw(surfaceDessin, (DataContext as VueModele).OutilSelectionne);
            if ((DataContext as VueModele).OutilSelectionne == "change_text")
            {
                icEventManager.ChangeText(surfaceDessin, mouseLeftDownPoint);
            }
            IsDrawing = false;
        }

        private void MessageTextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(messageTextBox.Text))
            {
                sendButton.IsEnabled = true;
            }
            else
            {
                sendButton.IsEnabled = false;
            }
        }
        private void AddImageToCanvas(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            bool? result = openFileDialog.ShowDialog();

            ImageBrush ib = new ImageBrush
            {
                ImageSource = new BitmapImage(new Uri(openFileDialog.FileName, UriKind.Relative))
            };
            double ratio = ib.ImageSource.Width / ib.ImageSource.Height;
            double imageWidth = Math.Min(ib.ImageSource.Width, surfaceDessin.ActualWidth);
            double imageHeight = Math.Min(ib.ImageSource.Height, surfaceDessin.ActualHeight);

            double finalWidth = Math.Min(imageWidth, imageHeight * ratio);
            double finalHeight = Math.Min(imageHeight, imageWidth / ratio);

            StylusPointCollection collection = new StylusPointCollection
            {
                new StylusPoint(0, 0),
                new StylusPoint(finalWidth, finalHeight)
            };

            ImageStroke image = new ImageStroke(collection, surfaceDessin, ib);
            (image as ICanvasable).AddToCanvas();
        }
        private void DownloadCanvasAsJPG(object sender, RoutedEventArgs e)
        {
            byte[] bitmap = GetBytesForImage();

            SaveFileDialog saveFileDialog = new SaveFileDialog
            {
                DefaultExt = ".png",
                Filter = "Image (.png)|*.png"
            };

            // Show save file dialog box
            bool? result = saveFileDialog.ShowDialog();
            MemoryStream ms = new MemoryStream(bitmap);
            System.Drawing.Image returnImage = System.Drawing.Image.FromStream(ms);
            using (System.Drawing.Image image = System.Drawing.Image.FromStream(new MemoryStream(bitmap)))
            {
                if (saveFileDialog.FileName != "")
                    image.Save(saveFileDialog.FileName, System.Drawing.Imaging.ImageFormat.Png);
            }

        }
        private async void Reinitialiser_Click(object sender, RoutedEventArgs e)
        {
            await (DataContext as VueModele).CollaborationClient.CollaborativeResetAsync();
        }

        private void ReceiveDraw(object sender, MessageArgs args)
        {
            DrawViewModel drawViewModel = JsonConvert.DeserializeObject<DrawViewModel>(args.Message);
            icEventManager.EndDraw(surfaceDessin, drawViewModel, username);
        }

        private void ReceiveSelect(object sender, MessageArgs args)
        {
            (DataContext as VueModele).SelectItemOnline(surfaceDessin, JsonConvert.DeserializeObject<SelectViewModel>(args.Message), username);
        }

        private void ReceiveDuplicate(object sender, MessageArgs args)
        {
            surfaceDessin.CopySelection();
            surfaceDessin.Paste();
        }

        private void ReceiveDelete(object sender, MessageArgs args)
        {
            surfaceDessin.CutSelection();
        }

        private void ReceiveReset(object sender, EventArgs args)
        {
            reinitialiser.Command = (DataContext as VueModele).Reinitialiser;
            reinitialiser.Command.Execute(reinitialiser.CommandParameter);
        }

        void InkCanvas_SelectionMoving(object sender, InkCanvasSelectionEditingEventArgs e)
        {
            icEventManager.RedrawConnections(surfaceDessin, (DataContext as VueModele).OutilSelectionne, e.OldRectangle, e.NewRectangle);
        }

        private void hamburgerMenu_Click(object sender, RoutedEventArgs e)
        {
            if (isMenuOpen)
            {
                chatMenu.Width = 70;
                chatTab.Visibility = Visibility.Collapsed;
                isMenuOpen = false;
            }
            else
            {
                chatMenu.Width = 775;
                chatTab.Visibility = Visibility.Visible;
                isMenuOpen = true;
            }
        }

        private void surfaceDessin_ChangeSelection(object sender, EventArgs e)
        {
            (DataContext as VueModele).ChangeSelection((sender as InkCanvas));
            // Add the rotating strokes adorner to the InkPresenter.
            if (adorner != null)
                adornerLayer.Remove(adorner);

            adornerLayer = AdornerLayer.GetAdornerLayer(surfaceDessin);
            adorner = new LineStrokeAdorner(surfaceDessin);

            adornerLayer.Add(adorner);
        }

        private void GoBack_Click(object sender, RoutedEventArgs e)
        {
            if (_viewState == ViewStateEnum.Online)
                externalChatWindow.Close();
            MenuProfile menuProfile = new MenuProfile();
            Application.Current.MainWindow = menuProfile;
            Close();
            menuProfile.Show();
        }
        void Window_Loaded(object sender, RoutedEventArgs e)
        {
        }
    }
}