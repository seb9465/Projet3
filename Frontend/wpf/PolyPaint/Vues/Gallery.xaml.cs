using MaterialDesignThemes.Wpf;
using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Modeles;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;
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
    /// 
    class UserDataContext
    {
        public VueModele VueModele { get; set; }
        public List<SaveableCanvas> Canvas { get; set; }
    }

    public partial class Gallery : Window
    {
        public List<SaveableCanvas> Canvas { get; set; }
        public SaveableCanvas SelectedCanvas { get; set; }
        private ImageProtection imageProtection;
        private StrokeBuilder strokeBuilder = new StrokeBuilder();
        private string username = Application.Current.Properties["username"].ToString();
        FenetreDessin fenetreDessin = new FenetreDessin(ViewStateEnum.Online);

        public String CanvasVisibility;
        public String CanvasName;
        public String CanvasProtection;
        public String CanvasAutor;

        private ChatWindow externalChatWindow;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }
        private MediaPlayer mediaPlayer = new MediaPlayer();
        private InkCanvas SurfaceDessin { get; set; }

        public Gallery(List<SaveableCanvas> strokes, InkCanvas drawingSurface)
        {
            InitializeComponent();
            Canvas = ConvertStrokesToPNG(strokes, drawingSurface);
            SurfaceDessin = drawingSurface;


            DataContext = new UserDataContext();
            (DataContext as UserDataContext).VueModele = new VueModele();
            (DataContext as UserDataContext).VueModele.ChatClient.Initialize((string)Application.Current.Properties["token"]);
            (DataContext as UserDataContext).VueModele.ChatClient.MessageReceived += ScrollDown;
            externalChatWindow = new ChatWindow((DataContext as UserDataContext).VueModele);
            (DataContext as UserDataContext).Canvas = Canvas;
          //  DataContext = Canvas; // Il faudrait reussir a utiliser plusieurs datacontext. Ici on a besoin du datacontext pour recuperer les donnee du chat ET des canvas. Cest pous ca que le chat marche pas dans la gallerie
            
            usernameLabel.Content = username;
        }


        private void NewCanva_Click(object sender, RoutedEventArgs e)
        {
            UploadToCloud uploadToCloud = new UploadToCloud();
            Application.Current.MainWindow = uploadToCloud;
            this.Close();
            uploadToCloud.Show();
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

        private List<SaveableCanvas> ConvertStrokesToPNG(List<SaveableCanvas> savedCanvas, InkCanvas drawingSurface)
        {
            List<SaveableCanvas> canvas = new List<SaveableCanvas>();
            if (savedCanvas != null)
            {
                for (int item = 0; item < savedCanvas.Count; item++)
                {
                    if (savedCanvas[item].CanvasAutor == username | savedCanvas[item].CanvasVisibility == "Public")
                    {
                        canvas.Add(new SaveableCanvas(savedCanvas[item].CanvasId, savedCanvas[item].Name, savedCanvas[item].Base64Strokes, savedCanvas[item].Base64Image, savedCanvas[item].CanvasVisibility, savedCanvas[item].CanvasProtection, savedCanvas[item].CanvasAutor));
                        for (int i = 0; i < canvas.Count - 1; i++)
                        {
                            if (savedCanvas[item].Name == canvas[i].Name)
                            {
                                canvas.RemoveAt(i);
                            }
                        }
                    }

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
            SelectedCanvas = (SaveableCanvas)ImagePreviews.SelectedItem;
            List<DrawViewModel> drawViewModels = JsonConvert.DeserializeObject<List<DrawViewModel>>(SelectedCanvas.Base64Strokes);
            if (SelectedCanvas.CanvasProtection != "")
            {
                imageProtection = new ImageProtection();
                if (imageProtection.PasswordEntered == SelectedCanvas.CanvasProtection)
                {
                    strokeBuilder.BuildStrokesFromDrawViewModels(drawViewModels, SurfaceDessin);
                    Application.Current.MainWindow = fenetreDessin;
                    this.Close();
                    fenetreDessin.Show();
                }
                else
                {
                    SelectedCanvas = null;
                    MessageBox.Show("Wrong password");
                }
            }
            else
            {
                strokeBuilder.BuildStrokesFromDrawViewModels(drawViewModels, SurfaceDessin);
                Application.Current.MainWindow = fenetreDessin;
                this.Close();
                fenetreDessin.Show();
            }
        }

    }
}
