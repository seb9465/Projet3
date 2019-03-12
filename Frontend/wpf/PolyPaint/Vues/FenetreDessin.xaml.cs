using MaterialDesignThemes.Wpf;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Win32;
using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Modeles;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using PolyPaint.Vues;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
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
        private ChatWindow externalChatWindow;
        private MediaPlayer mediaPlayer = new MediaPlayer();
        private InkCanvasEventManager icEventManager = new InkCanvasEventManager();
        private bool IsDrawing = false;
        private Point currentPoint, mouseLeftDownPoint;
        private HubConnection Connection;
        public event EventHandler MessageReceived;
        public event EventHandler SystemMessageReceived;
        private string username;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }

        public FenetreDessin(ViewStateEnum viewState)
        {
            InitializeComponent();
            _viewState = viewState;
            DataContext = new VueModele();

            if (_viewState == ViewStateEnum.Online)
            {
                object token = Application.Current.Properties["token"];
                username = Application.Current.Properties["username"].ToString();
                //token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InVzZXIuMyIsIm5hbWVpZCI6Ijg4OTU2NjlhLTYyMmMtNDk2ZS1iZTkwLTI4YTQzMGE3NzhhZSIsImZhbWlseV9uYW1lIjoidXNlcjMiLCJuYmYiOjE1NTIyNTY1ODgsImV4cCI6NjE1NTIyNTY1MjgsImlhdCI6MTU1MjI1NjU4OCwiaXNzIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUiLCJhdWQiOiJodHRwczovL3BvbHlwYWludC5tZSJ9._CGBRWU961rt14S5FTx9QuzFkTCX86iel2PiMZ_PzMs";
                ConnectToCollaborativeServer((string) token);
                (DataContext as VueModele).ChatClient.Initialize((string) Application.Current.Properties["token"]);
                (DataContext as VueModele).ChatClient.MessageReceived += ScrollDown;
                externalChatWindow = new ChatWindow(DataContext);
                Application.Current.Exit += OnClosing;

            }
            else
            {
                sendToCloud.Visibility = Visibility.Collapsed;
                importFromCloud.Visibility = Visibility.Collapsed;
                chatMenu.Visibility = Visibility.Collapsed;

                Thickness margin = surfaceDessin.Margin;
                margin.Right = -790;
                margin.Bottom = -260;
                surfaceDessin.Margin = margin;
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
            if (_viewState == ViewStateEnum.Online)
            {
                await CollaborativeDuplicateAsync();
            }
            else
            {
                surfaceDessin.CopySelection();
                surfaceDessin.Paste();
            }
        }

        private async void SupprimerSelection(object sender, RoutedEventArgs e)
        {
            if (_viewState == ViewStateEnum.Online)
            {
                await CollaborativeDeleteAsync();
            }
            else
            {
                surfaceDessin.CutSelection();
            }
        }
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
            List<SaveableCanvas> strokes;
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6Im9saXZpZXIubGF1em9uIiwibmFtZWlkIjoiMjY5MGYyMjAtN2JiYS00NDViLTgzYWEtMjIwZmVlMDczMTRiIiwiZmFtaWx5X25hbWUiOiJ1c2VyIiwibmJmIjoxNTUwNTkwMjgzLCJleHAiOjYxNTUwNTkwMjIzLCJpYXQiOjE1NTA1OTAyODMsImlzcyI6Imh0dHBzOi8vcG9seXBhaW50Lm1lIiwiYXVkIjoiaHR0cHM6Ly9wb2x5cGFpbnQubWUifQ.7zc5SqJNkJi7q8-SPzJ7Jbz1S5umsMszoJrxyBResVQ");
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/canvas");
                string responseString = await response.Content.ReadAsStringAsync();
                strokes = JsonConvert.DeserializeObject<List<SaveableCanvas>>(responseString);
            }
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
            surfaceDessin.Margin = new Thickness(0, 0, 0, 0);
            surfaceDessin.Measure(size);
            surfaceDessin.Arrange(new Rect(size));

            int margin = (int) surfaceDessin.Margin.Left;
            int width = (int) surfaceDessin.ActualWidth - margin;
            int height = (int) surfaceDessin.ActualHeight - margin;

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
            chat.Visibility = Visibility.Collapsed;
            ScrollDown(null, null);
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
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string) Application.Current.Properties["token"]);
                    System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                    client.GetAsync($"{Config.URL}/api/user/logout").Wait();
                }
            }
            catch { }
        }
        private async void InkCanvas_LeftMouseDown(object sender, MouseButtonEventArgs e)
        {
            mouseLeftDownPoint = e.GetPosition((IInputElement) sender);

            if ((DataContext as VueModele).OutilSelectionne == "select")
            {

                if (_viewState == ViewStateEnum.Online)
                {
                    SelectViewModel selectViewModel = new SelectViewModel
                    {
                        MouseLeftDownPointX = mouseLeftDownPoint.X,
                        MouseLeftDownPointY = mouseLeftDownPoint.Y,
                        Owner = username,
                    };
                    await CollaborativeSelectAsync(selectViewModel);
                }
                else
                {
                    icEventManager.SelectItemOffline(surfaceDessin, mouseLeftDownPoint);
                }
            }
            else
            {
                IsDrawing = true;
            }
        }
        private void InkCanvas_LeftMouseMove(object sender, MouseEventArgs e)
        {
            currentPoint = e.GetPosition((IInputElement) sender);
            if (IsDrawing)
            {
                icEventManager.DrawShape(surfaceDessin, (DataContext as VueModele).OutilSelectionne, currentPoint, mouseLeftDownPoint);
            }
        }

        private async void InkCanvas_LeftMouseUp(object sender, MouseButtonEventArgs e)
        {
            if (_viewState == ViewStateEnum.Online)
            {
                List<PolyPaintStylusPoint> points = new List<PolyPaintStylusPoint>();
                foreach (StylusPoint point in icEventManager.DrawingStroke.StylusPoints.ToList())
                {
                    points.Add(new PolyPaintStylusPoint()
                    {
                        PressureFactor = point.PressureFactor,
                        X = point.X,
                        Y = point.Y,
                    });
                }
                Enum.TryParse<ItemTypeEnum>(icEventManager.DrawingStroke.GetType().ToString(), out ItemTypeEnum itemType);

                PolyPaintColor color = new PolyPaintColor()
                {
                    A = icEventManager.DrawingStroke.DrawingAttributes.Color.A,
                    B = icEventManager.DrawingStroke.DrawingAttributes.Color.B,
                    G = icEventManager.DrawingStroke.DrawingAttributes.Color.G,
                    R = icEventManager.DrawingStroke.DrawingAttributes.Color.R,
                };
                DrawViewModel drawViewModel = new DrawViewModel
                {
                    OutilSelectionne = (DataContext as VueModele).OutilSelectionne,
                    StylusPoints = points,
                    ItemType = itemType,
                    Color = color,
                    Owner = username,
                };
                await CollaborativeDrawAsync(drawViewModel);
            }
            else
            {
                icEventManager.EndDraw(surfaceDessin, (DataContext as VueModele).OutilSelectionne);
            }
            if ((DataContext as VueModele).OutilSelectionne == "text")
            {
                icEventManager.ChangeText(surfaceDessin, mouseLeftDownPoint);
            }
            icEventManager.EndDraw(surfaceDessin, (DataContext as VueModele).OutilSelectionne);
            IsDrawing = false;

        }

        public async void ConnectToCollaborativeServer(string accessToken)
        {
            Connection =
                new HubConnectionBuilder()
                .WithUrl($"{Config.URL}/signalr/collaborative", options =>
                {
                    options.AccessTokenProvider = () => Task.FromResult(accessToken);
                })
                .Build();

            HandleMessages();
            await Connection.StartAsync();
        }


        private void DialogHost_DialogClosing(object sender, MaterialDesignThemes.Wpf.DialogClosingEventArgs eventArgs)
        {

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {

        }
        private async Task CollaborativeDrawAsync(DrawViewModel drawViewModel)
        {
            await Connection.InvokeAsync("Draw", JsonConvert.SerializeObject(drawViewModel));
        }
        private async Task CollaborativeSelectAsync(SelectViewModel selectViewModel)
        {
            await Connection.InvokeAsync("Select", selectViewModel);
        }
        private async Task CollaborativeDuplicateAsync()
        {
            object o = Clipboard.GetDataObject();

            await Connection.InvokeAsync("Duplicate");
        }
        private async Task CollaborativeDeleteAsync()
        {
            await Connection.InvokeAsync("Delete");
        }

        private async Task CollaborativeResetAsync()
        {
            await Connection.InvokeAsync("Reset", "general");
        }

        private void MessageTextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (!String.IsNullOrWhiteSpace(messageTextBox.Text))
            {
                sendButton.IsEnabled = true;
            }
            else
            {
                sendButton.IsEnabled = false;
            }
        }

        private async void Reinitialiser_Click(object sender, RoutedEventArgs e)
        {
            if (_viewState == ViewStateEnum.Online)
            {
                await CollaborativeResetAsync();
            }
        }

        private void HandleMessages()
        {
            Connection.On<string, string, string>("ReceiveMessage", (username, message, timestamp) =>
            {
                MessageReceived?.Invoke(this, new MessageArgs(username, message, timestamp));
            });
            Connection.On<string>("SystemMessage", (message) =>
            {
                Console.WriteLine(message);
            });
            Connection.On<string>("Draw", (drawViewModelString) =>
            {
                Dispatcher.Invoke(() =>
                {
                    DrawViewModel drawViewModel = JsonConvert.DeserializeObject<DrawViewModel>(drawViewModelString);
                    icEventManager.EndDraw(surfaceDessin, drawViewModel, username);
                });
            });
            Connection.On<SelectViewModel>("Select", (selectViewModel) =>
            {
                Dispatcher.Invoke(() =>
                {
                    icEventManager.SelectItemOnline(surfaceDessin, selectViewModel, username);
                });
            });
            Connection.On("Duplicate", () =>
            {
                Dispatcher.Invoke(() =>
                {
                    surfaceDessin.CopySelection();
                    surfaceDessin.Paste();
                });
            });
            Connection.On("Delete", () =>
            {
                Dispatcher.Invoke(() =>
                {
                    surfaceDessin.CutSelection();
                });
            });
            Connection.On("Reset", () =>
            {
                Dispatcher.Invoke(() =>
                {
                    reinitialiser.Command = (DataContext as VueModele).Reinitialiser;
                    reinitialiser.Command.Execute(reinitialiser.CommandParameter);
                });
            });
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
    }
}