﻿using MaterialDesignThemes.Wpf;
using Newtonsoft.Json;
using PolyPaint.Common.Collaboration;
using PolyPaint.Common.Messages;
using PolyPaint.Modeles;
using PolyPaint.Structures;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
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
    public partial class Gallery : Window
    {
        public List<SaveableCanvas> Canvas { get; set; }
        public SaveableCanvas SelectedCanvas { get; set; }
        private ImageProtection imageProtection;
        private StrokeBuilder strokeBuilder = new StrokeBuilder();
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

        public Gallery(List<SaveableCanvas> strokes, ChatClient chatClient)
        {
            InitializeComponent();
            Canvas = ConvertStrokesToPNG(strokes);

            DataContext = new UserDataContext(chatClient);
            
            externalChatWindow = new ChatWindow(DataContext as UserDataContext);
            (DataContext as UserDataContext).Canvas = Canvas;
            //  DataContext = Canvas; // Il faudrait reussir a utiliser plusieurs datacontext. Ici on a besoin du datacontext pour recuperer les donnee du chat ET des canvas. Cest pous ca que le chat marche pas dans la gallerie

            usernameLabel.Content = username;
            Closing += UnsubscribeDataContext;
        }

        private void UnsubscribeDataContext(object sender, CancelEventArgs e)
        {
            (DataContext as UserDataContext).UnsubscribeChatClient();
        }

        private void NewCanva_Click(object sender, RoutedEventArgs e)
        {
            UploadToCloud uploadToCloud = new UploadToCloud((DataContext as UserDataContext).ChatClient);
            Application.Current.MainWindow = uploadToCloud;
            this.Close();
            DataContext = null;
            uploadToCloud.Show();
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

        private List<SaveableCanvas> ConvertStrokesToPNG(List<SaveableCanvas> savedCanvas)
        {
            List<SaveableCanvas> canvas = new List<SaveableCanvas>();
            if (savedCanvas != null)
            {
                for (int item = 0; item < savedCanvas.Count; item++)
                {
                    if (savedCanvas[item].CanvasAutor == username | savedCanvas[item].CanvasVisibility == "Public")
                    {
                        canvas.Add(new SaveableCanvas(savedCanvas[item].CanvasId, savedCanvas[item].Name, savedCanvas[item].DrawViewModels, savedCanvas[item].Image, savedCanvas[item].CanvasVisibility, savedCanvas[item].CanvasProtection, savedCanvas[item].CanvasAutor));
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

        private void OnSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            SelectedCanvas = (SaveableCanvas)ImagePreviews.SelectedItem;
            List<DrawViewModel> drawViewModels = JsonConvert.DeserializeObject<List<DrawViewModel>>(SelectedCanvas.DrawViewModels);
            if (SelectedCanvas.CanvasProtection != "" && SelectedCanvas.CanvasAutor != username)
            {
                imageProtection = new ImageProtection();
                if (imageProtection.PasswordEntered == SelectedCanvas.CanvasProtection)
                {
                    FenetreDessin fenetreDessin = new FenetreDessin(drawViewModels, (DataContext as UserDataContext).ChatClient, SelectedCanvas.Name)
                    {
                        canvasAutor = SelectedCanvas.CanvasAutor,
                        canvasName = SelectedCanvas.Name,
                        canvasVisibility = SelectedCanvas.CanvasVisibility,
                        canvasProtection = SelectedCanvas.CanvasProtection
                    };
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
                FenetreDessin fenetreDessin = new FenetreDessin(drawViewModels, (DataContext as UserDataContext).ChatClient, SelectedCanvas.Name)
                {
                    canvasAutor = SelectedCanvas.CanvasAutor,
                    canvasName = SelectedCanvas.Name,
                    canvasVisibility = SelectedCanvas.CanvasVisibility,
                    canvasProtection = SelectedCanvas.CanvasProtection
                };
                Application.Current.MainWindow = fenetreDessin;
                this.Close();
                fenetreDessin.Show();
            }
        }

    }
}
