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
using PolyPaint.Chat;
using Microsoft.AspNetCore.SignalR.Client;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Logique d'interaction pour ChatWindow.xaml
    /// </summary>
    public partial class ChatWindow : Window
    {
        public ChatClient ChatClient { get; set; }

        public ChatWindow()
        {
            InitializeComponent();
            ChatClient = new ChatClient();
        }
        
        private async void connectButton_Click(object sender, RoutedEventArgs e)
        {
            ChatClient.connection.On<string, string>("ReceiveMessage", (username, message) =>
            {
                this.Dispatcher.Invoke(() =>
                {
                    var newMessage = $"{username}: {message}";
                    messagesList.Items.Add(newMessage);
                });
            });

            try
            {
                await ChatClient.connection.StartAsync();
                await ChatClient.connection.InvokeAsync("ConnectToGroup",
                    userTextBox.Text);
                messagesList.Items.Add("Connection started");
                connectButton.IsEnabled = false;
                sendButton.IsEnabled = true;
            }
            catch (Exception ex)
            {
                messagesList.Items.Add(ex.Message);
            }
        }

        private async void sendButton_Click(object sender, RoutedEventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(messageTextBox.Text))
            {
                try
                {
                    await ChatClient.connection.InvokeAsync("SendMessage",
                        messageTextBox.Text);

                    messageTextBox.Text = String.Empty;
                }
                catch (Exception ex)
                {
                    messagesList.Items.Add(ex.Message);
                }
            }
            messageTextBox.Focus();
        }

        private void DataWindow_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            e.Cancel = true;
            this.Hide();
        }

        private void enterKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                sendButton_Click(sender, e);
            }
        }
    }
}
