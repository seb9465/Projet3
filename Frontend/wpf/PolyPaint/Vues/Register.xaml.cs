using System;
using System.Data.SqlClient;
using System.Drawing;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using Microsoft.AspNetCore.Http;
using PolyPaint.VueModeles;

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

        private void IsEmailValid(object sender, RoutedEventArgs e)
        {
            string input = (sender as TextBox).Text;

            if (!Regex.IsMatch(input, @"^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$"))
            {
                InvalidEmail.Opacity = 100;
            } else
            {
                InvalidEmail.Opacity = 0;
            }
        }

        private void IsPasswordValid(object sender, RoutedEventArgs e)
        {
            string input = (sender as PasswordBox).Password;

            if (!Regex.IsMatch(input, @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,15}$"))
            {
                InvalidPassword.Opacity = 100;
            }
            else
            {
                InvalidPassword.Opacity = 0;
            }
        }
    }
}
