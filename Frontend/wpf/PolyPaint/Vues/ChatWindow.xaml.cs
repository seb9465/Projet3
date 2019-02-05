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
        public object ParentElement { get; }

        public ChatWindow(object dataContext)
        {
            InitializeComponent();
            DataContext = dataContext;
            (DataContext as VueModele).ChatClient.MessageReceived += AddMessage;
        }
        
        private void sendButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                (DataContext as VueModele).ChatClient.SendMessage(messageTextBox.Text);
            }
            catch (Exception ex)
            {
                messagesList.Items.Add(ex.Message);
            }
        }

        private void DataWindow_Closing(object sender, CancelEventArgs e)
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

        private void enterKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                sendButton_Click(sender, e);
            }
        }

         private void AddMessage(object sender, EventArgs args)
        {
            MessageArgs messArgs = args as MessageArgs;
            this.Dispatcher.Invoke(() =>
            {
                messagesList.Items.Add($"{messArgs.Username}: {messArgs.Message}\t{messArgs.Timestamp}");
            });
        }
    }
}
