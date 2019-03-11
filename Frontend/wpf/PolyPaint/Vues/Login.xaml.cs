using Newtonsoft.Json;
using PolyPaint.VueModeles;
using System;
using System.Net.Http;
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
        private Register register;
        public Login()
        {
            InitializeComponent();
            register = new Register();
        }

        private void OfflineBtn_Click(object sender, RoutedEventArgs e)
        {
            FenetreDessin fenetreDessin = new FenetreDessin(ViewStateEnum.Offline);
            Application.Current.MainWindow = fenetreDessin;
            Close();
            fenetreDessin.Show();
        }

        private async void LoginBtn_Click(object sender, RoutedEventArgs e)
        {
            errors_label.Content = "";
            LoginViewModel loginViewModel = new LoginViewModel()
            {
                Username = usernameBox.Text,
                Password = passwordBox.Password,
            };

            string json = JsonConvert.SerializeObject(loginViewModel);

            using (HttpClient client = new HttpClient())
            {
                client.BaseAddress = new System.Uri(Config.URL);
                client.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                StringContent content = new StringContent(json, Encoding.UTF8, "application/json");
                HttpResponseMessage result = await client.PostAsync("/api/login", content);
                object token = JsonConvert.DeserializeObject(await result.Content.ReadAsStringAsync());

                if (result.StatusCode == System.Net.HttpStatusCode.OK)
                {
                    Application.Current.Properties.Add("token", token);
                    FenetreDessin fenetreDessin = new FenetreDessin(ViewStateEnum.Online);
                    Application.Current.MainWindow = fenetreDessin;
                    Close();
                    fenetreDessin.Show();
                }
                else
                {
                    string error = await result.Content.ReadAsStringAsync();
                    errors_label.Content = error.ToString();
                }
            }
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
