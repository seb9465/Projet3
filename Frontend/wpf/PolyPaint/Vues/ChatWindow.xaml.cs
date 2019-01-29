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
        
        private async void sendButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                await (DataContext as VueModele).Connection.InvokeAsync("SendMessage",
                    messageTextBox.Text);
            }
            catch (Exception ex)
            {
                messagesList.Items.Add(ex.Message);
            }
        }
    }
}
