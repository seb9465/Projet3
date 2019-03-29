using MaterialDesignThemes.Wpf;
using PolyPaint.Modeles;
using PolyPaint.Structures;
using PolyPaint.VueModeles;
using PolyPaint.Vues;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;


namespace PolyPaint
{
    /// <summary>
    /// Interaction logic for MenuProfile.xaml
    /// </summary>
    public partial class MenuProfile : Window
    {
        private string username;
        private ChatWindow externalChatWindow;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }
        private MediaPlayer mediaPlayer = new MediaPlayer();

        public MenuProfile()
        {
            InitializeComponent();
            DataContext = new VueModele(_viewState);
            username = Application.Current.Properties["username"].ToString();
            usernameLabel.Content = username;

            object token = Application.Current.Properties["token"];
            (DataContext as VueModele).ChatClient.Initialize((string)Application.Current.Properties["token"]);
            (DataContext as VueModele).ChatClient.MessageReceived += ScrollDown;
            externalChatWindow = new ChatWindow(DataContext);

            Application.Current.Exit += OnClosing;
        }

        private void CanvasBtn_Click(object sender, RoutedEventArgs e)
        {
            externalChatWindow.Close();
            FenetreDessin fenetreDessin = new FenetreDessin(ViewStateEnum.Online);
            Application.Current.MainWindow = fenetreDessin;
            Close();
            fenetreDessin.Show();
        }

        private void GalleryBtn_Click(object sender, RoutedEventArgs e)
        {
            FenetreDessin fenetreDessin = new FenetreDessin(ViewStateEnum.Online);
            externalChatWindow.Close();
            //Gallery gallery = new Gallery(strokes,fenetreDessin.surfaceDessin);
            //Application.Current.MainWindow = gallery;
            Close();
            //gallery.Show();
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
            }
            else
            {
                chatMenu.Width = 775;
                chatTab.Visibility = Visibility.Visible;
                isMenuOpen = true;
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
    }
}
