using System;
using System.Net.Http;
using System.Windows;
using System.Windows.Controls;

namespace PolyPaint.Vues
{
    public partial class Register : Page
    {
        public Register()
        {
            InitializeComponent();
        }

        private void BackBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Content = new Login();
        }

        private void RegisterBtn_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
