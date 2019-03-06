using System;
using System.Net.Http;
using System.Windows;
using System.Windows.Controls;

namespace PolyPaint.Vues
{
    public partial class Register : Window
    {
        public Register()
        {
            InitializeComponent();
        }

        private void BackBtn_Click(object sender, RoutedEventArgs e)
        {
            Login login = new Login();
            Application.Current.MainWindow = login;
            Close();
            login.Show();
        }

        private void Register_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
