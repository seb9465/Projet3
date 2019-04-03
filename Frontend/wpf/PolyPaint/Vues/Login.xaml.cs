using Newtonsoft.Json;
using PolyPaint.Common;
using PolyPaint.Common.Collaboration;
using PolyPaint.Modeles;
using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Windows;
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
            FenetreDessin fenetreDessin = new FenetreDessin(new List<DrawViewModel>(), new ChatClient(), "offline");
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

            string json = JsonConvert.SerializeObject(loginViewModel);

            using (HttpClient client = new HttpClient())
            {
                HttpResponseMessage result = new HttpResponseMessage();
                string token = "";
                try
                {
                    client.BaseAddress = new System.Uri(Config.URL);
                    client.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
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

                    List<SaveableCanvas> strokes;
                    using (client)
                    {
                        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                        System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                        HttpResponseMessage response = await client.GetAsync($"{Config.URL}/api/user/AllCanvas");
                        string responseString = await response.Content.ReadAsStringAsync();
                        strokes = JsonConvert.DeserializeObject<List<SaveableCanvas>>(responseString);
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
                    //errors_label.Content = error.ToString();
                }
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
    }
}
