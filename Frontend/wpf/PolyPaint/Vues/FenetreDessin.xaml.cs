using MaterialDesignThemes.Wpf;
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
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
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
        private AdornerLayer adornerLayer;
        private LineStrokeAdorner adorner;
        private ConcurrentDictionary<string, OnlineSelectedAdorner> _onlineSelectedAdorners;

        public SaveableCanvas Canvas = new SaveableCanvas();


        private ChatWindow externalChatWindow;
        private MediaPlayer mediaPlayer = new MediaPlayer();
        private InkCanvasEventManager icEventManager = new InkCanvasEventManager();
        private bool IsDrawing = false;
        private Point currentPoint, mouseLeftDownPoint;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }

        private (StrokeCollection, StrokeCollection) CurrentChange = (new StrokeCollection(), new StrokeCollection());
        private Stack<(StrokeCollection, StrokeCollection)> UndoStack { get; set; }
        private Stack<(StrokeCollection, StrokeCollection)> RedoStack { get; set; }
        public bool IsMoving { get; set; } = false;
        public bool IsResizing { get; set; } = false;
        public bool IsSliding { get; private set; } = false;
        public double ThicknessBefore { get; private set; }
        public double ThicknessAfter { get; private set; }

        public FenetreDessin(List<DrawViewModel> drawViewModels, SaveableCanvas canvas, ChatClient chatClient)
        {
            InitializeComponent();
            DataContext = new VueModele(chatClient, canvas, surfaceDessin);

            (DataContext as VueModele).CollaborationClient.Initialize((string)Application.Current.Properties["token"]);
            (DataContext as VueModele).CollaborationClient.DrawReceived += ReceiveDraw;
            (DataContext as VueModele).CollaborationClient.SelectReceived += ReceiveSelect;
            (DataContext as VueModele).CollaborationClient.DuplicateReceived += ReceiveDuplicate;
            (DataContext as VueModele).CollaborationClient.DeleteReceived += ReceiveDelete;
            (DataContext as VueModele).CollaborationClient.ResetReceived += ReceiveReset;
            (DataContext as VueModele).CollaborationClient.ResizeCanvasReceived += ReceiveResizeCanvas;
            (DataContext as VueModele).CollaborationClient.KickedReceived += LeaveCanvas;
            (DataContext as VueModele).CollaborationClient.ProtectionChanged += HandleProtectionChanged;
            (DataContext as VueModele).CollaborationClient.ClientConnected += SendSelectedStrokesToOthers;
            (DataContext as VueModele).PropertyChanged += VueModelePropertyChanged;

            (DataContext as VueModele).OnRotation += UpdateAdorner;

            (DataContext as VueModele).ChooseBorder.Executed += Undoable_Executed;
            (DataContext as VueModele).Rotate.Executed += Undoable_Executed;

            _onlineSelectedAdorners = new ConcurrentDictionary<string, OnlineSelectedAdorner>();
            externalChatWindow = new ChatWindow(DataContext);

            StrokeBuilder.BuildStrokesFromDrawViewModels(drawViewModels, surfaceDessin);
            (DataContext as VueModele).Traits = surfaceDessin.Strokes;

            surfaceDessin.Width = canvas.CanvasWidth;
            surfaceDessin.Height = canvas.CanvasHeight;
            Canvas = canvas;

            UndoStack = new Stack<(StrokeCollection, StrokeCollection)>();
            RedoStack = new Stack<(StrokeCollection, StrokeCollection)>();

            Closing += Unselect;
        }

        private void Unselect(object sender, CancelEventArgs e)
        {
            (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(new List<DrawViewModel>());
        }

        private void Undo(object sender, EventArgs e)
        {
            var change = UndoStack.Pop();
            if (UndoStack.Count == 0) (DataContext as VueModele).UndoEnabled = false;
            RedoStack.Push(change);
            (DataContext as VueModele).RedoEnabled = true;
            if (change.Item1 == null || change.Item1.Count == 0)
            {
                var toRemove = new StrokeCollection(surfaceDessin.Strokes.Where(x => change.Item2.Select(y => (y as AbstractStroke).Guid).Contains((x as AbstractStroke).Guid)));
                surfaceDessin.Strokes.Remove(toRemove);
                (DataContext as VueModele).SelectNothing();
                (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(new List<DrawViewModel>());
                (DataContext as VueModele).CollaborationClient.CollaborativeDeleteAsync(StrokeBuilder.GetDrawViewModelsFromStrokes(toRemove));
            }
            else
            {
                var dvms = StrokeBuilder.GetDrawViewModelsFromStrokes(change.Item1);
                StrokeBuilder.BuildStrokesFromDrawViewModels(dvms, surfaceDessin);
                InkCanvasEventManager.UpdateAnchorPointsPositionFor(new StrokeCollection(surfaceDessin.Strokes.Where(x => change.Item1.Select(y => (y as AbstractStroke).Guid).Contains((x as AbstractStroke).Guid))), surfaceDessin);
                StrokeCollection sCollection = new StrokeCollection(surfaceDessin.Strokes.Where(x => dvms.Select(y => y.Guid).Contains((x as AbstractStroke).Guid.ToString())).ToList());
                (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(dvms);
                (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(dvms);
                Dispatcher.Invoke(() =>
                {
                    (DataContext as VueModele).SelectItems(sCollection);
                });
            }
            ReplaceAdorner();
            SendToCloud();
        }

        private void Redo(object sender, EventArgs e)
        {
            var change = RedoStack.Pop();
            if (RedoStack.Count == 0) (DataContext as VueModele).RedoEnabled = false;
            UndoStack.Push(change);
            (DataContext as VueModele).UndoEnabled = true;
            if (change.Item2 == null || change.Item2.Count == 0)
            {
                var toRemove = new StrokeCollection(surfaceDessin.Strokes.Where(x => change.Item1.Select(y => (y as AbstractStroke).Guid).Contains((x as AbstractStroke).Guid)));
                surfaceDessin.Strokes.Remove(toRemove);
                (DataContext as VueModele).SelectNothing();
                (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(new List<DrawViewModel>());
                (DataContext as VueModele).CollaborationClient.CollaborativeDeleteAsync(StrokeBuilder.GetDrawViewModelsFromStrokes(toRemove));
            }
            else
            {
                var dvms = StrokeBuilder.GetDrawViewModelsFromStrokes(change.Item2);
                StrokeBuilder.BuildStrokesFromDrawViewModels(dvms, surfaceDessin);
                InkCanvasEventManager.UpdateAnchorPointsPositionFor(new StrokeCollection(surfaceDessin.Strokes.Where(x => change.Item2.Select(y => (y as AbstractStroke).Guid).Contains((x as AbstractStroke).Guid))), surfaceDessin);
                StrokeCollection sCollection = new StrokeCollection(surfaceDessin.Strokes.Where(x => dvms.Select(y => y.Guid).Contains((x as AbstractStroke).Guid.ToString())).ToList());
                (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(dvms);
                (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(dvms);
                Dispatcher.Invoke(() =>
                {
                    (DataContext as VueModele).SelectItems(sCollection);
                });
            }
            ReplaceAdorner();
            SendToCloud();
        }

        private void HandleProtectionChanged(object sender, MessageArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                var protectionMessage = JsonConvert.DeserializeObject<ProtectionMessage>(e.Message);
                (DataContext as VueModele).CanvasProtection = protectionMessage.IsProtected;
            });
        }

        private void VueModelePropertyChanged(object sender, PropertyChangedEventArgs args)
        {
            if (args.PropertyName == "OutilSelectionne" && (DataContext as VueModele).OutilSelectionne != "select")
            {
                (DataContext as VueModele).SelectNothing();
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

        private void DupliquerSelection(object sender, RoutedEventArgs e)
        {

            var strokes = StrokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
            if (strokes.Count != 0)
            {
                Clipboard.SetText(JsonConvert.SerializeObject(strokes));
            }

            try
            {
                var drawviewmodels = JsonConvert.DeserializeObject<List<DrawViewModel>>(Clipboard.GetText());
                drawviewmodels.ForEach(x => x.Guid = Guid.NewGuid().ToString());
                drawviewmodels.ForEach(x => x.StylusPoints.ForEach(y => y.X += 10));
                drawviewmodels.ForEach(x => x.StylusPoints.ForEach(y => y.Y += 10));
                StrokeBuilder.BuildStrokesFromDrawViewModels(drawviewmodels, surfaceDessin);

                StrokeCollection sCollection = new StrokeCollection(surfaceDessin.Strokes.Where(x => drawviewmodels.Select(y => y.Guid).Contains((x as AbstractStroke).Guid.ToString())).ToList());


                (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(drawviewmodels);
                (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(drawviewmodels);
                SendToCloud();
                Dispatcher.Invoke(() =>
                {
                    (DataContext as VueModele).SelectItems(sCollection);
                });
            }
            catch (Exception allo)
            {
                Console.WriteLine(allo.ToString());
            }
        }

        private void SupprimerSelection(object sender, RoutedEventArgs e)
        {
            List<DrawViewModel> strokes = StrokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
            surfaceDessin.CutSelection();
            Clipboard.SetText(JsonConvert.SerializeObject(strokes));
            (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(new List<DrawViewModel>());
            (DataContext as VueModele).CollaborationClient.CollaborativeDeleteAsync(strokes);
            SendToCloud();
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

                // Rebuild the strokes1
                StrokeBuilder.BuildStrokesFromDrawViewModels(customStrokes, surfaceDessin);
            }
            catch (ArgumentException) { } // Close Dialog Window
        }


        private void ResizeCanva_Click(object sender, RoutedEventArgs e)
        {
            ResizeCanvas resizeCanvas = new ResizeCanvas(surfaceDessin.Width, surfaceDessin.Height);
            surfaceDessin.Width = resizeCanvas.CanvasWidth > Config.MAX_CANVAS_WIDTH ? Config.MAX_CANVAS_WIDTH : resizeCanvas.CanvasWidth;
            surfaceDessin.Height = resizeCanvas.CanvasHeight > Config.MAX_CANVAS_HEIGHT ? Config.MAX_CANVAS_HEIGHT : resizeCanvas.CanvasHeight;
            Canvas.CanvasWidth = resizeCanvas.CanvasWidth > Config.MAX_CANVAS_WIDTH ? Config.MAX_CANVAS_WIDTH : resizeCanvas.CanvasWidth;
            Canvas.CanvasHeight = resizeCanvas.CanvasHeight > Config.MAX_CANVAS_HEIGHT ? Config.MAX_CANVAS_HEIGHT : resizeCanvas.CanvasHeight;
            (DataContext as VueModele).CollaborationClient.CollaborativeResizeCanvasAsync(new Point(surfaceDessin.Width, surfaceDessin.Height));
            SendToCloud();
        }

        private void ToggleProtection(object sender, RoutedEventArgs e)
        {
            if ((DataContext as VueModele).CanvasProtection)
            {
                ActivateProtection promptPassword = new ActivateProtection();
                promptPassword.Closing += (s, a) =>
                {
                    if (promptPassword.Password.Length > 0)
                    {
                        Canvas.CanvasProtection = promptPassword.Password;
                        SendToCloud();
                        (DataContext as VueModele).CollaborationClient.CollaborativeChangeProtectionAsync(Canvas.CanvasId, true);
                    }
                    else
                    {
                        (DataContext as VueModele).CanvasProtection = !(DataContext as VueModele).CanvasProtection;
                    }
                };
                promptPassword.ShowDialog();
                // kick les autres
            }
            else
            {
                Canvas.CanvasProtection = "";
                SendToCloud();
                (DataContext as VueModele).CollaborationClient.CollaborativeChangeProtectionAsync(Canvas.CanvasId, false);
            }
        }

        private async void SendToCloud()
        {
            byte[] strokesBytes = GetBytesForStrokes();
            byte[] imageBytes = GetBytesForImage();
            List<DrawViewModel> drawViewModels = StrokeBuilder.GetDrawViewModelsFromStrokes((DataContext as VueModele).Traits);
            string json = JsonConvert.SerializeObject(drawViewModels);
            Canvas.DrawViewModels = json;
            Canvas.Image = imageBytes;

            string canvasJson = JsonConvert.SerializeObject(Canvas);
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                StringContent content = new StringContent(canvasJson, Encoding.UTF8, "application/json");
                try
                {
                    HttpResponseMessage response = await client.PostAsync($"{Config.URL}/api/user/canvas", content);
                    string responseString = await response.Content.ReadAsStringAsync();
                    if (!(DataContext as VueModele).IsConnected)
                    {
                        MessageBox.Show("Connection has been retrieved. All changes were pushed.");
                        (DataContext as VueModele).IsConnected = true;
                        (DataContext as VueModele).IsCreatedByUser = Canvas.CanvasAutor == Application.Current.Properties["username"].ToString();
                    }
                }
                catch (Exception)
                {
                    (DataContext as VueModele).IsCreatedByUser = false;
                    (DataContext as VueModele).IsConnected = false;
                    MessageBox.Show("Connection has been lost. All changes are saved locally until reconnection (or application exit).");
                }
            }

        }

        private async void ImportFromCloud(object sender, RoutedEventArgs e)
        {
            progressBar.Visibility = Visibility.Visible;
            ObservableCollection<SaveableCanvas> strokes;
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/AllCanvas");
                string responseString = await response.Content.ReadAsStringAsync();
                strokes = JsonConvert.DeserializeObject<ObservableCollection<SaveableCanvas>>(responseString);
            }

            await UnsubscribeToServer();

            progressBar.Visibility = Visibility.Collapsed;
            Gallery gallery = new Gallery(strokes, (DataContext as VueModele).ChatClient);
            Application.Current.MainWindow = gallery;
            surfaceDessin.Strokes.Clear();
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
                (DataContext as VueModele).SelectItem(mouseLeftDownPoint);
                CurrentChange.Item1 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
            }
            else
            {
                CurrentChange.Item1 = null;
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
                    var window = icEventManager.ChangeText(surfaceDessin, mouseLeftDownPoint, (VueModele)DataContext);
                    (DataContext as VueModele).SelectItem(e.GetPosition((IInputElement)sender));
                    selectedItems = StrokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(selectedItems);
                    CurrentChange.Item1 = surfaceDessin.GetSelectedStrokes().Clone();
                    window.Closing += (object zender, CancelEventArgs eee) =>
                    {
                        CurrentChange.Item2 = surfaceDessin.GetSelectedStrokes().Clone();
                        AddToUndoStack();
                    };
                    break;
                case "select":
                    var selectedStrokes = surfaceDessin.GetSelectedStrokes();
                    selectedItems = StrokeBuilder.GetDrawViewModelsFromStrokes(selectedStrokes);
                    (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(selectedItems);
                    if (IsMoving)
                    {
                        var affectedStrokes = InkCanvasEventManager.UpdateAnchorPointsPosition(surfaceDessin);
                        if (!affectedStrokes.Any(x => selectedStrokes.Select(y => (y as AbstractStroke).Guid).Contains((x as AbstractStroke).Guid))) affectedStrokes.Add(selectedStrokes);
                        var affectedItems = StrokeBuilder.GetDrawViewModelsFromStrokes(affectedStrokes);

                        (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(affectedItems);

                        CurrentChange.Item2 = new StrokeCollection(selectedStrokes).Clone();
                        if (CurrentChange.Item1 != null && CurrentChange.Item1.Count > 0 &&
                            CurrentChange.Item2 != null && CurrentChange.Item2.Count > 0 &&
                            (CurrentChange.Item1[0] as AbstractStroke).Center != (CurrentChange.Item2[0] as AbstractStroke).Center)
                        {
                            AddToUndoStack();
                        }
                    }
                    IsResizing = false;
                    IsMoving = false;
                    break;
                case "lasso":
                    (DataContext as VueModele).SelectItemLasso(bounds);
                    selectedItems = StrokeBuilder.GetDrawViewModelsFromStrokes(surfaceDessin.GetSelectedStrokes());
                    (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(selectedItems);
                    (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(selectedItems);
                    break;
                default:
                    icEventManager.EndDrawAsync(surfaceDessin, (DataContext as VueModele));
                    CurrentChange.Item2 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
                    AddToUndoStack();
                    break;
            }

            SendToCloud();


            IsDrawing = false;
        }

        private void AddToUndoStack()
        {
            UndoStack.Push(CurrentChange);
            RedoStack.Clear();
            (DataContext as VueModele).UndoEnabled = true;
            (DataContext as VueModele).RedoEnabled = false;
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
            OpenFileDialog openFileDialog = new OpenFileDialog()
            {
                DefaultExt = ".png",
                Filter = "Image (.png)|*.png"
            };
            bool? result = openFileDialog.ShowDialog();

            if (result ?? false && openFileDialog.FileName != null)
            {
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
                image.StylusPoints[0] = new StylusPoint();
                image.StylusPoints[1] = new StylusPoint(imageWidth, imageHeight);
                image.Width = imageWidth;
                image.Height = imageHeight;
                (image as ICanvasable).AddToCanvas();
                (DataContext as VueModele).CollaborationClient.CollaborativeDrawAsync(StrokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection(new List<Stroke>() { image })));
                SendToCloud();
            }
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
        private void Reinitialiser_Click(object sender, RoutedEventArgs e)
        {
            CurrentChange.Item1 = surfaceDessin.Strokes.Clone();
            CurrentChange.Item2 = new StrokeCollection();
            AddToUndoStack();
            (DataContext as VueModele).Reinitialiser.Execute(null);
            (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(new List<DrawViewModel>());
            (DataContext as VueModele).CollaborationClient.CollaborativeResetAsync();
            SendToCloud();
            ReplaceAdorner();
        }

        private void ReceiveDraw(object sender, MessageArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                var message = JsonConvert.DeserializeObject<ItemsMessage>(args.Message);

                StrokeBuilder.BuildStrokesFromDrawViewModels(message.Items, surfaceDessin);
                InkCanvasEventManager.UpdateAnchorPointsPosition(surfaceDessin);
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
                var message = JsonConvert.DeserializeObject<ItemsMessage>(args.Message);
                surfaceDessin.Strokes.Remove(new StrokeCollection(surfaceDessin.Strokes.Where(x => message.Items.Any(y => y.Guid == (x as AbstractStroke).Guid.ToString()))));
            });
        }

        private void ReceiveReset(object sender, EventArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                (DataContext as VueModele).Reinitialiser.Execute(null);
                (DataContext as VueModele).SelectNothing();
                ReplaceAdorner();
            });
        }

        private void ReceiveResizeCanvas(object sender, MessageArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                var sizeMessage = JsonConvert.DeserializeObject<SizeMessage>(args.Message);
                surfaceDessin.Width = sizeMessage.Size.X;
                surfaceDessin.Height = sizeMessage.Size.Y;
                Canvas.CanvasWidth = sizeMessage.Size.X;
                Canvas.CanvasHeight = sizeMessage.Size.Y;
            });
        }

        private void SendSelectedStrokes(object sender, RoutedEventArgs e)
        {
            (DataContext as VueModele).SendSelectedStrokes();
        }

        private void SendSelectedStrokesToOthers(object sender, RoutedEventArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                var strokes = surfaceDessin.GetSelectedStrokes();
                var items = StrokeBuilder.GetDrawViewModelsFromStrokes(strokes);
                (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(items);
                (DataContext as VueModele).SelectItems(strokes);
            });
        }

        void InkCanvas_SelectionMoving(object sender, InkCanvasSelectionEditingEventArgs e)
        {
            if (!IsMoving)
            {
                CurrentChange.Item1 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
            }
            IsMoving = true;
            var selectedStrokes = surfaceDessin.GetSelectedStrokes();
            if (selectedStrokes.Count == 1 && selectedStrokes[0] is AbstractLineStroke && ((AbstractLineStroke)selectedStrokes[0]).Snapped)
                e.Cancel = true;
            else if (selectedStrokes.Count > 1 && !CanMove())
                e.Cancel = true;
            else if (selectedStrokes.Count == 1 && selectedStrokes[0] is AbstractLineStroke)
            {
                var newX = (selectedStrokes[0] as AbstractLineStroke).LastElbowPosition.X + e.NewRectangle.X - e.OldRectangle.X;
                var newY = (selectedStrokes[0] as AbstractLineStroke).LastElbowPosition.Y + e.NewRectangle.Y - e.OldRectangle.Y;
                (selectedStrokes[0] as AbstractLineStroke).LastElbowPosition = new Point(newX, newY);
            }
        }

        private bool CanMove()
        {
            var selectedconnections = surfaceDessin.GetSelectedStrokes().Where(x => x is AbstractLineStroke);
            var scedrick = surfaceDessin.Strokes.Where(x => x is AbstractShapeStroke && ((x as AbstractShapeStroke).InConnections.Any(y => selectedconnections.Select(z => (z as AbstractStroke).Guid).Contains(y.Key)) || (x as AbstractShapeStroke).OutConnections.Any(y => selectedconnections.Select(z => (z as AbstractStroke).Guid).Contains(y.Key))));
            return scedrick.All(x => surfaceDessin.GetSelectedStrokes().Select(y => (y as AbstractStroke).Guid).Contains((x as AbstractStroke).Guid));
        }

        void InkCanvas_SelectionResizing(object sender, InkCanvasSelectionEditingEventArgs e)
        {
            if (!IsResizing)
            {
                CurrentChange.Item1 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
            }
            IsResizing = true;
            var selectedStrokes = surfaceDessin.GetSelectedStrokes();
            if (selectedStrokes.Count == 1 && selectedStrokes[0] is AbstractLineStroke && ((AbstractLineStroke)selectedStrokes[0]).Snapped)
                e.Cancel = true;
        }

        void UpdateAdorner(object sender, EventArgs e)
        {
            ReplaceAdorner();
        }

        private void ReplaceAdorner()
        {
            if (adorner != null)
                adornerLayer.Remove(adorner);

            adornerLayer = AdornerLayer.GetAdornerLayer(surfaceDessin);
            adorner = new LineStrokeAdorner(surfaceDessin);
            adorner.ElbowChanging += BeginMoveElbow;
            adorner.ElbowChanged += FinishMoveElbow;
            adornerLayer.Add(adorner);
        }

        private void BeginMoveElbow(object sender, EventArgs e)
        {
            CurrentChange.Item1 = surfaceDessin.GetSelectedStrokes().Clone();
        }

        private void FinishMoveElbow(object sender, EventArgs e)
        {
            CurrentChange.Item2 = surfaceDessin.GetSelectedStrokes().Clone();
            AddToUndoStack();
        }

        private void ContextualMenu_Click(object sender, EventArgs e)
        {
            icEventManager.ContextualMenuClick(surfaceDessin, (sender as MenuItem).Name, (DataContext as VueModele));
            SendToCloud();
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
                chatMenu.Width = 500;
                chatTab.Visibility = Visibility.Visible;
                isMenuOpen = true;
            }
        }

        private void showTutorial(object sender, RoutedEventArgs e)
        {
            Tutoriel tutoriel = new Tutoriel();
        }

        private void surfaceDessin_ChangeSelection(object sender, EventArgs e)
        {
            (DataContext as VueModele).ChangeSelection(sender as InkCanvas);
            // Add the rotating strokes adorner to the InkPresenter.
            ReplaceAdorner();
        }

        private async void Disconnect_Click(object sender, RoutedEventArgs e)
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

            await UnsubscribeToServer();

            Application.Current.Properties.Clear();
            Login login = new Login();
            Application.Current.MainWindow = login;
            Close();
            login.Show();
        }

        private async Task UnsubscribeToServer()
        {
            (DataContext as VueModele).CollaborationClient.DrawReceived -= ReceiveDraw;
            (DataContext as VueModele).CollaborationClient.SelectReceived -= ReceiveSelect;
            (DataContext as VueModele).CollaborationClient.DuplicateReceived -= ReceiveDuplicate;
            (DataContext as VueModele).CollaborationClient.DeleteReceived -= ReceiveDelete;
            (DataContext as VueModele).CollaborationClient.ResetReceived -= ReceiveReset;
            (DataContext as VueModele).CollaborationClient.ResizeCanvasReceived -= ReceiveResizeCanvas;
            (DataContext as VueModele).CollaborationClient.KickedReceived -= LeaveCanvas;
            (DataContext as VueModele).CollaborationClient.ProtectionChanged -= HandleProtectionChanged;
            (DataContext as VueModele).CollaborationClient.ClientConnected -= SendSelectedStrokesToOthers;
            (DataContext as VueModele).CollaborationClient.CollaborativeSelectAsync(new List<DrawViewModel>());
            (DataContext as VueModele).PropertyChanged -= VueModelePropertyChanged;
            await (DataContext as VueModele).CollaborationClient.Disconnect();
            await (DataContext as VueModele).UnsubscribeChatClient();
        }

        private void LeaveCanvas(object sender, MessageArgs e)
        {
            Dispatcher.Invoke(() =>
            {
                ImportFromCloud(sender, new RoutedEventArgs());
                MessageBox.Show("You got kicked out of the canvas");
            });
        }

        private void surfaceDessin_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            e.Handled = true;
        }

        private void selecteurCouleurBordure_PreviewMouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0)
                CurrentChange.Item1 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
        }

        private void selecteurCouleurBordure_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0)
            {
                CurrentChange.Item2 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
                AddToUndoStack();
            }
            SendSelectedStrokes(sender, e);
        }

        private void selecteurCouleurRemplissage_PreviewMouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0)
                CurrentChange.Item1 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
        }

        private void selecteurCouleurRemplissage_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0)
            {
                CurrentChange.Item2 = new StrokeCollection(surfaceDessin.GetSelectedStrokes()).Clone();
                AddToUndoStack();
            }
            SendSelectedStrokes(sender, e);
        }

        private void Slider_PreviewMouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0 && !IsSliding)
            {
                ThicknessBefore = slider.Value;
                var sColl = new StrokeCollection();
                foreach (var stroke in surfaceDessin.GetSelectedStrokes().Clone())
                {
                    var border = (stroke as AbstractStroke).Border.Clone();
                    var newStroke = stroke.Clone();
                    (newStroke as AbstractStroke).Border = border;
                    sColl.Add(newStroke.Clone());
                }
                CurrentChange.Item1 = new StrokeCollection(sColl.Clone()).Clone();
            }
            IsSliding = true;
        }

        private void Slider_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0)
            {
                ThicknessAfter = slider.Value;
                var sColl = new StrokeCollection();
                foreach (var stroke in surfaceDessin.GetSelectedStrokes().Clone())
                {
                    var border = (stroke as AbstractStroke).Border.Clone();
                    var newStroke = stroke.Clone();
                    (newStroke as AbstractStroke).Border = border;
                    sColl.Add(newStroke.Clone());
                }
                CurrentChange.Item2 = new StrokeCollection(sColl.Clone()).Clone();
                AddToUndoStack();
                IsSliding = false;
            }
            SendSelectedStrokes(sender, e);
        }

        private void button_WhatsBefore(object sender, MouseButtonEventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0)
            {
                var sColl = new StrokeCollection();
                foreach (var stroke in surfaceDessin.GetSelectedStrokes().Clone())
                {
                    var border = (stroke as AbstractStroke).Border.Clone();
                    var newStroke = stroke.Clone();
                    (newStroke as AbstractStroke).Border = border;
                    sColl.Add(newStroke.Clone());
                }
                CurrentChange.Item1 = new StrokeCollection(sColl.Clone()).Clone();
            }
        }

        private void Undoable_Executed(object sender, EventArgs e)
        {
            if (surfaceDessin.GetSelectedStrokes().Count > 0)
            {
                var sColl = new StrokeCollection();
                foreach (var stroke in surfaceDessin.GetSelectedStrokes().Clone())
                {
                    var border = (stroke as AbstractStroke).Border.Clone();
                    var newStroke = stroke.Clone();
                    (newStroke as AbstractStroke).Border = border;
                    sColl.Add(newStroke.Clone());
                }
                CurrentChange.Item2 = new StrokeCollection(sColl.Clone()).Clone();
                AddToUndoStack();
            }
        }

        void Window_Loaded(object sender, RoutedEventArgs e)
        {
        }
    }
}