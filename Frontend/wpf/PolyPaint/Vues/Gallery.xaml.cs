using MaterialDesignThemes.Wpf;
using PolyPaint.Modeles;
using PolyPaint.Structures;
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
        FenetreDessin fenetreDessin = new FenetreDessin(ViewStateEnum.Online);

        public String CanvasVisibility;
        public String CanvasName;
        public String CanvasProtection;

        private ChatWindow externalChatWindow;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }
        private MediaPlayer mediaPlayer = new MediaPlayer();

        public Gallery(List<SaveableCanvas> strokes, InkCanvas drawingSurface)
        {
            InitializeComponent();
            Canvas = ConvertStrokesToPNG(strokes, drawingSurface);


            DataContext = new VueModele();
            (DataContext as VueModele).ChatClient.Initialize((string)Application.Current.Properties["token"]);
            (DataContext as VueModele).ChatClient.MessageReceived += ScrollDown;
            externalChatWindow = new ChatWindow(DataContext);

            DataContext = Canvas; // Il faudrait reussir a utiliser plusieurs datacontext. Ici on a besoin du datacontext pour recuperer les donnee du chat ET des canvas. Cest pous ca que le chat marche pas dans la gallerie
            username = Application.Current.Properties["username"].ToString();
            usernameLabel.Content = username;
        }


        private void NewCanva_Click(object sender, RoutedEventArgs e)
        {
            UploadToCloud uploadToCloud = new UploadToCloud();

            CanvasName = uploadToCloud.CanvasName;
            CanvasVisibility = uploadToCloud.CanvasVisibility;
            CanvasProtection = uploadToCloud.CanvasProtection;

            Application.Current.MainWindow = fenetreDessin;
            this.Close();
            fenetreDessin.Show();

            
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

        private void hamburgerMenu_Click(object sender, RoutedEventArgs e)
        {
            if (isMenuOpen)
            {
                chatMenu.Width = 70;
                chatTab.Visibility = Visibility.Collapsed;
                isMenuOpen = false;
                canvasStackPanel.Width = 1070;
            }
            else
            {
                chatMenu.Width = 500;
                chatTab.Visibility = Visibility.Visible;
                isMenuOpen = true;
                canvasStackPanel.Width = 620;
            }
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
                    fenetreDessin.surfaceDessin.Strokes.Add(SelectedCanvas.Strokes);
                    Application.Current.MainWindow = fenetreDessin;
                    this.Close();
                    fenetreDessin.Show();
                } else
                {
                    SelectedCanvas = null;
                    MessageBox.Show("Wrong password");
                }
            } else
            {
                fenetreDessin.surfaceDessin.Strokes.Add(SelectedCanvas.Strokes);
                Application.Current.MainWindow = fenetreDessin;
                this.Close();
                fenetreDessin.Show();
            }
        }
        
    }
}
