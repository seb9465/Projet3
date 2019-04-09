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
using Microsoft.AspNetCore.SignalR.Client;
using PolyPaint.Structures;
using System.ComponentModel;
using MaterialDesignThemes.Wpf;
using PolyPaint.Modeles;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Logique d'interaction pour ChatWindow.xaml
    /// </summary>
    public partial class ChatWindow : Window
    {

        public ChatWindow(object dataContext)
        {
            InitializeComponent();
            DataContext = dataContext;
    }

        private void DataWindow_Closing(object sender, CancelEventArgs e)
        {
            e.Cancel = true;
            this.Hide();
            foreach (Window window in Application.Current.Windows)
            {
                if (window.GetType() == typeof(FenetreDessin))
                {
                    (window as FenetreDessin).chatWrapper.Visibility = Visibility.Visible;
                } else if (window.GetType() == typeof(Gallery))
                {
                    (window as Gallery).chatWrapper.Visibility = Visibility.Visible;
                }
            }
        }

        private void enterKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                sendButton_Click(sender, e);
            }
        }

        private void AddRoom(object sender, DialogClosingEventArgs eventArgs)
        {
            if (!Equals(eventArgs.Parameter, true)) return;

            if (!string.IsNullOrWhiteSpace(roomTextBox.Text))
            {
                (DataContext as IChatDataContext).ChatClient.CreateChannel(roomTextBox.Text.Trim());
            }
            clearRoomName(sender, eventArgs);
        }

        private void clearRoomName(object sender, RoutedEventArgs e)
        {
            roomTextBox.Text = "";
        }

        private void sendButton_Click(object sender, RoutedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(messageTextBox.Text))
            {
                (DataContext as IChatDataContext).ChatClient.SendMessage(messageTextBox.Text, (DataContext as IChatDataContext).CurrentRoom);
            }
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

        private void ScrollDown(object sender, MessageArgs args)
        {
            Dispatcher.Invoke(() =>
            {
                messagesList.SelectedIndex = messagesList.Items.Count - 1;
                messagesList.ScrollIntoView(messagesList.SelectedItem);
            });
        }
        
    }
}
