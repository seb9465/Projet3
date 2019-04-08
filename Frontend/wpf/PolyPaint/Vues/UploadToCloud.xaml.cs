using Newtonsoft.Json;
using PolyPaint.Modeles;
using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Controls;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Logique d'interaction pour UploadToCloud.xaml
    /// </summary>
    public partial class UploadToCloud : Window, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        public ChatClient ChatClient;
        private bool _isProtected;
        public bool IsProtected
        {
            get { return _isProtected; }
            set
            {
                _isProtected = value;
                ProprieteModifiee();
                if (passwordTextBox != null && !_isProtected) passwordTextBox.Clear();
            }
        }

        public UploadToCloud(ChatClient chatClient)
        {
            DataContext = this;
            InitializeComponent();
            ChatClient = chatClient;
            _isProtected = protectionComboBox.Text == "Protected";
            this.ShowDialog();
        }

        protected virtual void ProprieteModifiee([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            var canvas = new SaveableCanvas(Guid.NewGuid().ToString(), nameTextBox.Text, "[]", new byte[0], visibilityComboBox.Text, passwordTextBox.Password, Application.Current.Properties["username"].ToString(), Config.MAX_CANVAS_WIDTH, Config.MAX_CANVAS_HEIGHT);

            FenetreDessin fenetreDessin = new FenetreDessin(new List<Common.Collaboration.DrawViewModel>(), canvas, ChatClient);

            Application.Current.MainWindow = fenetreDessin;
            Close();
            fenetreDessin.Show();
        }

        private void protectionComboBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        {
            IsProtected = (string)((ComboBoxItem)e.AddedItems[0]).Content == "Protected";
        }
    }
}
