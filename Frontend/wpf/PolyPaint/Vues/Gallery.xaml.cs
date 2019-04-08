using MaterialDesignThemes.Wpf;
using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Modeles;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for Gallery.xaml
    /// </summary>
    /// 
    public partial class Gallery : Window
    {
        public ObservableCollection<SaveableCanvas> Canvas { get; set; }
        public SaveableCanvas SelectedCanvas { get; set; }
        private string username = Application.Current.Properties["username"].ToString();

        public String CanvasVisibility;
        public String CanvasName;
        public String CanvasProtection;
        public String CanvasAutor;

        private ChatWindow externalChatWindow;
        bool isMenuOpen = false;
        private ViewStateEnum _viewState { get; set; }
        private MediaPlayer mediaPlayer = new MediaPlayer();
        private InkCanvas SurfaceDessin { get; set; }
        private double _currentWidth;
        private double _currentHeight;

        public Gallery(ObservableCollection<SaveableCanvas> strokes, ChatClient chatClient)
        {
            InitializeComponent();
            Canvas = GetAvailableCanvas(strokes);

            DataContext = new UserDataContext(chatClient);

            externalChatWindow = new ChatWindow(DataContext as UserDataContext);
            (DataContext as UserDataContext).Canvas = Canvas;
            
            usernameLabel.Content = username;

            Loaded += async (sender, e) =>
            {

                using (HttpClient client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                    System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                    HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/tutorial");
                    string responseString = await response.Content.ReadAsStringAsync();

                    if (responseString == "false")
                    {
                        Tutoriel tuto = new Tutoriel();
                    }
                }
            };

            Closing += UnsubscribeDataContext;
        }

        private void UnsubscribeDataContext(object sender, CancelEventArgs e)
        {
            (DataContext as UserDataContext).UnsubscribeChatClient();
        }

        private void NewCanva_Click(object sender, RoutedEventArgs e)
        {
            UploadToCloud uploadToCloud = new UploadToCloud((DataContext as UserDataContext).ChatClient);
           
        }

        private void AddRoom(object sender, DialogClosingEventArgs eventArgs)
        {
            if (!Equals(eventArgs.Parameter, true)) return;

            if (!string.IsNullOrWhiteSpace(roomTextBox.Text))
            {
                (DataContext as UserDataContext).ChatClient.CreateChannel(roomTextBox.Text.Trim());
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
                (DataContext as UserDataContext).ChatClient.SendMessage(messageTextBox.Text, (DataContext as UserDataContext).CurrentRoom);
            }
            mediaPlayer.Open(new Uri("SoundEffects//send.mp3", UriKind.Relative));
            mediaPlayer.Volume = 100;
            mediaPlayer.Play();
            messageTextBox.Text = String.Empty;
            messageTextBox.Focus();
        }

        private async void RefreshGallery_Click(object sender, RoutedEventArgs e)
        {
            ObservableCollection<SaveableCanvas> strokes;
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/AllCanvas");
                string responseString = await response.Content.ReadAsStringAsync();
                strokes = JsonConvert.DeserializeObject<ObservableCollection<SaveableCanvas>>(responseString);
            }
            (DataContext as UserDataContext).Canvas = GetAvailableCanvas(strokes);
        }
        private void hamburgerMenu_Click(object sender, RoutedEventArgs e)
        {
            if (isMenuOpen)
            {
                chatMenu.Width = 70;
                chatTab.Visibility = Visibility.Collapsed;
                isMenuOpen = false;
                canvasStackPanel.Width = _currentWidth - 200;
                canvasStackPanel.Margin = new Thickness(70, 0, 0, 0);
            }
            else
            {
                chatMenu.Width = 500;
                chatTab.Visibility = Visibility.Visible;
                isMenuOpen = true;
                canvasStackPanel.Width = _currentWidth - 200 - 430;
                canvasStackPanel.Margin = new Thickness(0, 0, 0, 0);
            }
        }
        private void Gallery_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            _currentHeight = e.NewSize.Height;
            _currentWidth = e.NewSize.Width;

            if (!isMenuOpen)
            {
                chatMenu.Width = 70;
                chatTab.Visibility = Visibility.Collapsed;
                isMenuOpen = false;
                canvasStackPanel.Width = _currentWidth - 200;
                canvasStackPanel.Margin = new Thickness(70, 0, 0, 0);
            }
            else
            {
                chatMenu.Width = 500;
                chatTab.Visibility = Visibility.Visible;
                isMenuOpen = true;
                canvasStackPanel.Width = _currentWidth - 200 - 430;
                canvasStackPanel.Margin = new Thickness(0, 0, 0, 0);
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

        private ObservableCollection<SaveableCanvas> GetAvailableCanvas(ObservableCollection<SaveableCanvas> savedCanvas)
        {
            ObservableCollection<SaveableCanvas> canvas = new ObservableCollection<SaveableCanvas>();
            if (savedCanvas != null)
            {
                for (int item = 0; item < savedCanvas.Count; item++)
                {
                    if (savedCanvas[item].CanvasAutor == username | savedCanvas[item].CanvasVisibility == "Public")
                    {
                        canvas.Add(new SaveableCanvas(savedCanvas[item].CanvasId, savedCanvas[item].Name, savedCanvas[item].DrawViewModels, savedCanvas[item].Image, savedCanvas[item].CanvasVisibility, savedCanvas[item].CanvasProtection, savedCanvas[item].CanvasAutor, savedCanvas[item].CanvasWidth, savedCanvas[item].CanvasHeight));
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
        private async void OnSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            SelectedCanvas = (SaveableCanvas)ImagePreviews.SelectedItem;
            var canvases = new ObservableCollection<SaveableCanvas>();
            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/AllCanvas");
                string responseString = await response.Content.ReadAsStringAsync();
                canvases = JsonConvert.DeserializeObject<ObservableCollection<SaveableCanvas>>(responseString);
            }
            SelectedCanvas = canvases.FirstOrDefault(x => x.CanvasId == (ImagePreviews.SelectedItem as SaveableCanvas).CanvasId);
            List<DrawViewModel> drawViewModels = JsonConvert.DeserializeObject<List<DrawViewModel>>(SelectedCanvas.DrawViewModels);
            if (SelectedCanvas.CanvasProtection != "" && SelectedCanvas.CanvasAutor != username)
            {
                var prompt = new PromptPassword(SelectedCanvas, drawViewModels, (DataContext as UserDataContext).ChatClient);
                prompt.Closing += (a, n) =>
                {
                    if(prompt.Password == SelectedCanvas.CanvasProtection)
                    {
                        Close();
                    }
                };
                prompt.ShowDialog();
                SelectedCanvas = null;
            }
            else
            {
                FenetreDessin fenetreDessin = new FenetreDessin(drawViewModels, SelectedCanvas, (DataContext as UserDataContext).ChatClient);
                Application.Current.MainWindow = fenetreDessin;
                Close();
                fenetreDessin.Show();
            }
        }
        private void showTutorial(object sender, RoutedEventArgs e)
        {
            Tutoriel tutoriel = new Tutoriel();
        }

    }
}
