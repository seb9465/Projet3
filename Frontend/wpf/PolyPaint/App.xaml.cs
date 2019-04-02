using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Windows;

namespace PolyPaint
{
    /// <summary>
    /// Logique d'interaction pour App.xaml
    /// </summary>
    public partial class App : Application
    {
        public App()
        {
            ShutdownMode = ShutdownMode.OnMainWindowClose;
            Exit += Logout;
        }

        private void Logout(object sender, EventArgs e)
        {
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", (string)Application.Current.Properties["token"]);
                    System.Net.ServicePointManager.ServerCertificateValidationCallback = (senderX, certificate, chain, sslPolicyErrors) => { return true; };
                    client.GetAsync($"{Config.URL}/api/user/logout").Wait();
                }
            }
            catch { }
        }
    }
}
