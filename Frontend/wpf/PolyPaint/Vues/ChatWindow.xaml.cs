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
            (DataContext as VueModele).ChatClient.MessageReceived += ScrollDown;
        }

        private void sendButton_Click(object sender, RoutedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(messageTextBox.Text))
            {
                (DataContext as VueModele).ChatClient.SendMessage(messageTextBox.Text, (DataContext as VueModele).CurrentRoom);
            }
            messageTextBox.Text = String.Empty;
            messageTextBox.Focus();
        }

        private void DataWindow_Closing(object sender, CancelEventArgs e)
        {
            e.Cancel = true;
            Hide();
        }

        private void enterKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                sendButton_Click(sender, e);
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
