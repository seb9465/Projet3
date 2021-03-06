﻿using Newtonsoft.Json;
using PolyPaint.Common;
using PolyPaint.Common.Collaboration;
using PolyPaint.Modeles;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Logique d'interaction pour Login.xaml
    /// </summary>
    public partial class Login : Window
    {
        public Login()
        {
            InitializeComponent();
        }

        private void OfflineBtn_Click(object sender, RoutedEventArgs e)
        {
            FenetreDessin fenetreDessin = new FenetreDessin(new List<DrawViewModel>(), new SaveableCanvas(), new ChatClient());
            Application.Current.MainWindow = fenetreDessin;
            Close();
            fenetreDessin.Show();
        }

        private async void LoginBtn_Click(object sender, RoutedEventArgs e)
        {
            // errors_label.Content = "";
            LoginViewModel loginViewModel = new LoginViewModel()
            {
                Username = usernameBox.Text,
                Password = passwordBox.Password,
            };
            //LoginViewModel loginViewModel = new LoginViewModel()
            //{
            //    Username = "alexis",
            //    Password = "!12345Aa",
            //};
            loginBtn.IsEnabled = false;

            string json = JsonConvert.SerializeObject(loginViewModel);

            using (HttpClient client = new HttpClient())
            {
                HttpResponseMessage result = new HttpResponseMessage();
                string token = "";
                try
                {
                    client.BaseAddress = new Uri(Config.URL);
                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                    StringContent content = new StringContent(json, Encoding.UTF8, "application/json");
                    result = await client.PostAsync("/api/login", content);
                    token = JsonConvert.DeserializeObject<string>(await result.Content.ReadAsStringAsync());
                }
                catch (JsonReaderException exc)
                {
                    Console.WriteLine(exc.Message);
                }

                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                {

                    DecodeToken(token);

                    ObservableCollection<SaveableCanvas> strokes;
                    using (client)
                    {
                        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                        System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                        HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/AllCanvas");
                        string responseString = await response.Content.ReadAsStringAsync();
                        strokes = JsonConvert.DeserializeObject<ObservableCollection<SaveableCanvas>>(responseString);
                    }

                    ChatClient chatClient = new ChatClient();
                    chatClient.Initialize((string)Application.Current.Properties["token"]);

                    Gallery gallery = new Gallery(strokes, chatClient);

                    Application.Current.MainWindow = gallery;


                    Close();
                    gallery.Show();
                }
                else
                {
                    string error = await result.Content.ReadAsStringAsync();
                    loginError.Text = JsonConvert.DeserializeObject<string>(error);
                }
                loginBtn.IsEnabled = true;
            }
        }

        private void RegisterBtn_Click(object sender, RoutedEventArgs e)
        {
            Register register = new Register();
            Application.Current.MainWindow = register;
            Close();
            register.Show();
        }
        private void DecodeToken(string token)
        {
            var handler = new JwtSecurityTokenHandler();
            var userToken = handler.ReadToken(token) as JwtSecurityToken;
            Application.Current.Properties.Add("token", token);
            Application.Current.Properties.Add("username", userToken.Claims.First(claim => claim.Type == "unique_name").Value);
        }

        private void Window_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                if (loginBtn.IsEnabled)
                {
                    LoginBtn_Click(sender, e);
                }
            }
        }

        private void FieldsUpdate(object sender, RoutedEventArgs e)
        {
            if (String.IsNullOrWhiteSpace(usernameBox.Text) || String.IsNullOrWhiteSpace(passwordBox.Password))
            {
                loginBtn.IsEnabled = false;
            }
            else
            {
                loginBtn.IsEnabled = true;
            }
        }

        private async void Button_ClickAsync(object sender, RoutedEventArgs e)
        {
            using (HttpClient client = new HttpClient())
            {
                string token = "";
                client.BaseAddress = new Uri(Config.URL);
                var web = new WebBrowserWindow();
                WinInetHelper.SupressCookiePersist();
                web.ShowDialog();
                token = web.Token;

                if (token != null && web.Result != null && web.Result.StatusCode == System.Net.HttpStatusCode.OK)
                {

                    DecodeToken(token);

                    ObservableCollection<SaveableCanvas> strokes;
                    using (client)
                    {
                        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                        System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                        HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/AllCanvas");
                        string responseString = await response.Content.ReadAsStringAsync();
                        strokes = JsonConvert.DeserializeObject<ObservableCollection<SaveableCanvas>>(responseString);
                    }

                    ChatClient chatClient = new ChatClient();
                    chatClient.Initialize((string)Application.Current.Properties["token"]);

                    Gallery gallery = new Gallery(strokes, chatClient);

                    Application.Current.MainWindow = gallery;


                    Close();
                    gallery.Show();
                }
                else
                {
                    string error = web.Result == null ? "" : await web.Result.Content.ReadAsStringAsync();
                    loginError.Text = JsonConvert.DeserializeObject<string>(error);
                }
            }
        }
    }
}
