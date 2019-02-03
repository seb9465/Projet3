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

namespace PolyPaint.Vues
{
    /// <summary>
    /// Logique d'interaction pour ChatWindow.xaml
    /// </summary>
    public partial class ChatWindow : Window
    {

        public ChatWindow()
        {
            InitializeComponent();
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

        private void connectButton_Click(object sender, RoutedEventArgs e)
        {
            string accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImFsZXhpc2xvaXNlbGxlIiwibmFtZWlkIjoiYzNkYWUwYzctNTFhNy00MWE4LTg0ZDYtODZkNzI0OTEwMzgyIiwibmJmIjoxNTQ5MTU5NTg0LCJleHAiOjYxNTQ5MTU5NTI0LCJpYXQiOjE1NDkxNTk1ODQsImlzcyI6IjEwLjIwMC4yNy4xNjo1MDAxIiwiYXVkIjoiMTAuMjAwLjI3LjE2OjUwMDEifQ.qj0TmQ5FeUf9FxwTy-QcikbhFlpyucK_oQXyxJkrDi4";
            try
            {
                (DataContext as VueModele).ChatClient.Initialize(accessToken);
                (DataContext as VueModele).ChatClient.MessageReceived += AddMessage;
                messagesList.Items.Add("Connection started");
                connectButton.IsEnabled = false;
                sendButton.IsEnabled = true;
            }
            catch (Exception ex)
            {
                messagesList.Items.Add(ex.Message);
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
