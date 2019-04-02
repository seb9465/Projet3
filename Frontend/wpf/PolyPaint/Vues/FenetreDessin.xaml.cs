using MaterialDesignThemes.Wpf;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Win32;
using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Common.Messages;
using PolyPaint.Modeles;
using PolyPaint.Strokes;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using PolyPaint.Vues;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
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
        private ConcurrentDictionary<string, OnlineSelectedAdorner> _onlineSelectedAdorners;

        public String canvasVisibility = "";
        public String canvasName = "";
        public String canvasProtection= "";
        public String canvasAutor = "";

        private ChatWindow externalChatWindow;
        private MediaPlayer mediaPlayer = new MediaPlayer();
        private InkCanvasEventManager icEventManager = new InkCanvasEventManager();
        private StrokeBuilder strokeBuilder = new StrokeBuilder();
        private bool IsDrawing = false;
        private Point currentPoint, mouseLeftDownPoint;
        private HubConnection Connection;
        public event EventHandler MessageReceived;
        private string username;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }

        public FenetreDessin(List<DrawViewModel> drawViewModels, ChatClient chatClient)
        {
            InitializeComponent();
            DataContext = new VueModele(chatClient);

            (DataContext as VueModele).CollaborationClient.Initialize((string)Application.Current.Properties["token"]);
            (DataContext as VueModele).CollaborationClient.DrawReceived += ReceiveDraw;
            (DataContext as VueModele).CollaborationClient.SelectReceived += ReceiveSelect;
            (DataContext as VueModele).CollaborationClient.DuplicateReceived += ReceiveDuplicate;
            (DataContext as VueModele).CollaborationClient.DeleteReceived += ReceiveDelete;
            (DataContext as VueModele).CollaborationClient.ResetReceived += ReceiveReset;
            (DataContext as VueModele).PropertyChanged += VueModelePropertyChanged;

            DispatcherTimer dispatcherTimer = new System.Windows.Threading.DispatcherTimer();
            dispatcherTimer.Tick += new EventHandler(SaveImage);
            dispatcherTimer.Interval = new TimeSpan(0, 1, 0);
            dispatcherTimer.Start();
            

            _onlineSelectedAdorners = new ConcurrentDictionary<string, OnlineSelectedAdorner>();
            externalChatWindow = new ChatWindow(DataContext);

            rebuilder.BuildStrokesFromDrawViewModels(drawViewModels, surfaceDessin);
        }

        private void VueModelePropertyChanged(object sender, PropertyChangedEventArgs args)
        {
            if (args.PropertyName == "OutilSelectionne" && (DataContext as VueModele).OutilSelectionne != "select")
            {
                (DataContext as VueModele).SelectNothing(surfaceDessin);
                (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(new List<DrawViewModel>());

            }
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
        private void surfaceDessin_MouseMove(object sender, MouseEventArgs e)
        {

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

                try
                {
                    fs = new FileStream(filePath, FileMode.Create);
                    var jsons = JsonConvert.SerializeObject(strokes);
                    fs.Write(Encoding.UTF8.GetBytes(jsons), 0, Encoding.UTF8.GetByteCount(jsons));
                }
                catch (ArgumentException) { } // Close Dialog Window
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
            try
            {
                fs = new FileStream(openFileDialog.FileName, FileMode.Open, FileAccess.Read);
                byte[] jsons = new byte[fs.Length];
                fs.Read(jsons, 0, (int)fs.Length);

                List<DrawViewModel> customStrokes = JsonConvert.DeserializeObject<List<DrawViewModel>>(Encoding.UTF8.GetString(jsons));

                // Rebuild the strokes
                rebuilder.BuildStrokesFromDrawViewModels(customStrokes, surfaceDessin);
            }
            catch (ArgumentException) { } // Close Dialog Window
        }


        private void ResizeCanva_Click(object sender, RoutedEventArgs e)
        {
            ResizeCanvas resizeCanvas = new ResizeCanvas();
            surfaceDessin.Width = resizeCanvas.CanvasWidth;
            surfaceDessin.Height = resizeCanvas.CanvasHeight;
        }

        private async void SendToCloud()
        {
            byte[] strokesBytes = GetBytesForStrokes();
            byte[] imageBytes = GetBytesForImage();
            List<DrawViewModel> drawViewModels = strokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.Strokes);
            string json = JsonConvert.SerializeObject(drawViewModels);
            string imageToSend = Convert.ToBase64String(imageBytes);
            string CanvasId = DateTime.Now.ToString("yyyy.MM.dd.hh.mm.ss.ffff");
            string CanvasName = canvasName;
            string CanvasVisibility = canvasVisibility;
            string CanvasProtection = canvasProtection;
            string CanvasAutor = canvasAutor;
            SaveableCanvas canvas = new SaveableCanvas(CanvasId, CanvasName, json, imageToSend, CanvasVisibility, CanvasProtection, CanvasAutor);

            string canvasJson = JsonConvert.SerializeObject(canvas);
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
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
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/canvas");
                string responseString = await response.Content.ReadAsStringAsync();
                strokes = JsonConvert.DeserializeObject<List<SaveableCanvas>>(responseString);
            }
            progressBar.Visibility = Visibility.Collapsed;
            Gallery gallery = new Gallery(strokes, (DataContext as VueModele).ChatClient);

            Application.Current.MainWindow = gallery;


            surfaceDessin.Strokes.Clear();
            //  surfaceDessin.Strokes.Add(gallery.SelectedCanvas.Strokes);

            Close();
            gallery.Show();
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

        private void InkCanvas_LeftMouseDown(object sender, MouseButtonEventArgs e)
        {
            mouseLeftDownPoint = e.GetPosition((IInputElement)sender);

            if ((DataContext as VueModele).OutilSelectionne == "select")
            {
                (DataContext as VueModele).SelectItem(surfaceDessin, mouseLeftDownPoint);
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

        private void InkCanvas_LeftMouseUp(object sender, MouseButtonEventArgs e)
        {
            if ((DataContext as VueModele).OutilSelectionne == "") return;
            var bounds = Rect.Empty;
            if (surfaceDessin.EditingMode == InkCanvasEditingMode.Select)
            {
                bounds = surfaceDessin.GetSelectionBounds();
            }

            var selectedItems = new List<DrawViewModel>();
            switch ((DataContext as VueModele).OutilSelectionne)
            {
                case "change_text":
                    icEventManager.ChangeText(surfaceDessin, mouseLeftDownPoint, (VueModele)DataContext);
                    (DataContext as VueModele).SelectItem(surfaceDessin, e.GetPosition((IInputElement)sender));
                    selectedItems = rebuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(selectedItems);
                    break;
                case "select":
                    selectedItems = rebuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(selectedItems);
                    (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(selectedItems);
                    break;
                case "lasso":
                    (DataContext as VueModele).SelectItemLasso(surfaceDessin, bounds);
                    selectedItems = rebuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(selectedItems);
                    (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(selectedItems);
                    break;
                default:
                    icEventManager.EndDrawAsync(surfaceDessin, (DataContext as VueModele));
                    break;
            }

            SendToCloud();


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
            (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(rebuilder.GetDrawViewModelsFromStrokes(new StrokeCollection(new List<Stroke>() { image })));
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
            Dispatcher.Invoke(() =>
            {
                var message = JsonConvert.DeserializeObject<ItemsMessage>(args.Message);
                icEventManager.EndDraw(surfaceDessin, message.Items, username);
            });
        }

        private void ReceiveSelect(object sender, MessageArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                var message = JsonConvert.DeserializeObject<ItemsMessage>(args.Message);
                (DataContext as VueModele).ChangeOnlineSelection(message);
                if (_onlineSelectedAdorners.TryGetValue(message.Username, out var adorner))
                    adornerLayer.Remove(adorner);

                var pair = new KeyValuePair<string, List<DrawViewModel>>(message.Username, message.Items);
                adornerLayer = AdornerLayer.GetAdornerLayer(surfaceDessin);
                _onlineSelectedAdorners.AddOrUpdate(message.Username, new OnlineSelectedAdorner(surfaceDessin, pair), (k, v) => { return new OnlineSelectedAdorner(surfaceDessin, pair); });
                adornerLayer.Add(_onlineSelectedAdorners[message.Username]);
            });
        }

        private void ReceiveDuplicate(object sender, MessageArgs args)
        {
        }

        private void ReceiveDelete(object sender, MessageArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                surfaceDessin.CutSelection();
            });
        }

        private void ReceiveReset(object sender, EventArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                reinitialiser.Command = (DataContext as VueModele).Reinitialiser;
                reinitialiser.Command.Execute(reinitialiser.CommandParameter);
            });
        }

        private void SendSelectedStrokes(object sender, RoutedEventArgs e)
        {
            (DataContext as VueModele).SendSelectedStrokes();
        }

        void InkCanvas_SelectionMoving(object sender, InkCanvasSelectionEditingEventArgs e)
        {
            icEventManager.RedrawConnections(surfaceDessin, (DataContext as VueModele).OutilSelectionne, e.OldRectangle, e.NewRectangle);
        }
        private void ContextualMenu_Click(object sender, EventArgs e)
        {
            icEventManager.ContextualMenuClick(surfaceDessin, (sender as MenuItem).Name, (DataContext as VueModele));
        }

        private void hamburgerMenu_Click(object sender, RoutedEventArgs e)
        {
            if (isMenuOpen)
            {
                chatMenu.Width = 70;
                chatTab.Visibility = Visibility.Collapsed;
                isMenuOpen = false;
                surfaceDessin.Width = 1200;
            }
            else
            {
                chatMenu.Width = 500;
                chatTab.Visibility = Visibility.Visible;
                isMenuOpen = true;
                surfaceDessin.Width = 800;
            }
        }

        private void surfaceDessin_ChangeSelection(object sender, EventArgs e)
        {
            (DataContext as VueModele).ChangeSelection(sender as InkCanvas);
            // Add the rotating strokes adorner to the InkPresenter.
            if (adorner != null)
                adornerLayer.Remove(adorner);

            adornerLayer = AdornerLayer.GetAdornerLayer(surfaceDessin);
            adorner = new LineStrokeAdorner(surfaceDessin);

            adornerLayer.Add(adorner);
        }

private void Disconnect_Click(object sender, RoutedEventArgs e)
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
            Application.Current.Properties.Clear();
            Login login = new Login();
            Application.Current.MainWindow = login;
            Close();
            login.Show();
        }
       
        void Window_Loaded(object sender, RoutedEventArgs e)
        {
        }
    }

}