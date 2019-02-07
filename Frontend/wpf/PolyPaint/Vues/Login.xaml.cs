using System.Windows;
using System.Net.Http;
using PolyPaint.VueModeles;
using System.Text;
using Newtonsoft.Json;
using System.Windows.Input;
using System;

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
            /*          FenetreDessin main = new FenetreDessin();
                      App.Current.MainWindow = main;
                      this.Close();
                      main.Show();*/
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
                client.BaseAddress = new System.Uri("https://polypaint.me");
                client.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                var result = await client.PostAsync("/api/login", content);
                var token = JsonConvert.DeserializeObject(await result.Content.ReadAsStringAsync());

                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                {
                    Application.Current.Properties.Add("token", token);
                    FenetreDessin fenetreDessin = new FenetreDessin();
                    Application.Current.MainWindow = fenetreDessin;
                    Close();
                    fenetreDessin.Show();
                }
            }
        }

        private void Window_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                LoginBtn_Click(sender, e);
            }
        }
       
    }
}
