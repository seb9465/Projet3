﻿using System.Windows;
using System.Net.Http;
using PolyPaint.VueModeles;
using System.Text;
using Newtonsoft.Json;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Logique d'interaction pour Login.xaml
    /// </summary>
    public partial class Login : Window
    {
        private Register register;
        public Login()
        {
            InitializeComponent();
            register = new Register();
        }

        private void OfflineBtn_Click(object sender, RoutedEventArgs e)
        {
            FenetreDessin main = new FenetreDessin();
            Application.Current.MainWindow = main;
            this.Close();
            main.Show();
        }

        private async void LoginBtn_Click(object sender, RoutedEventArgs e)
        {
            LoginViewModel loginViewModel = new LoginViewModel()
            {
                Username = usernameBox.Text,
                Password = passwordBox.Password,
            };

            var json = JsonConvert.SerializeObject(loginViewModel);

            using (var client = new HttpClient())
            {
                client.BaseAddress = new System.Uri("http://10.200.16.225:4000");
                client.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var result = await client.PostAsync("/api/login", content);
                var token = JsonConvert.DeserializeObject(await result.Content.ReadAsStringAsync());

                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                {
                    Application.Current.Properties.Add("token", token);
                    FenetreDessin fenetreDessin = new FenetreDessin();
                    fenetreDessin.Show();
                    this.Close();
                }
            }
        }
    }
}
