using Newtonsoft.Json;
using PolyPaint.Modeles;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Windows;
using System.Windows.Navigation;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for WebBrowserWindow.xaml
    /// </summary>
    public partial class WebBrowserWindow : Window
    {
        public string Token { get; set; }
        public HttpResponseMessage Result{ get; set; }

        public WebBrowserWindow()
        {
            InitializeComponent();
            Loaded += FacebookLogin;
            webBrowser.Navigated += CheckToken;
        }

        private async void CheckToken(object sender, NavigationEventArgs e)
        {
            if (e.Uri.ToString().ToLower().StartsWith($"{Config.URL}/signin-facebook"))
            {
                webBrowser.Visibility = Visibility.Collapsed;
                var token = e.Uri.Fragment.Split('&')[0].Replace("#access_token=", "");
                using (var client = new HttpClient())
                {
                    var result = await client.GetAsync($"https://graph.facebook.com/me?fields=id,first_name,last_name,email&access_token={token}");
                    var responseString = await result.Content.ReadAsStringAsync();
                    var fbInfo = JsonConvert.DeserializeObject<FBInfo>(responseString);

                    var ppfbinfo = new PolyPaintFBInfo()
                    {
                        Username = fbInfo.Id,
                        FirstName = fbInfo.First_Name,
                        LastName = fbInfo.Last_Name,
                        Email = fbInfo.Email,
                        Fbtoken = token
                    };

                    var json = JsonConvert.SerializeObject(ppfbinfo);
                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                    StringContent content = new StringContent(json, Encoding.UTF8, "application/json");
                    result = await client.PostAsync($"{Config.URL}/api/login/ios-callback", content);
                    Result = result;
                    Token = JsonConvert.DeserializeObject<string>(await result.Content.ReadAsStringAsync());
                }
                Close();
            }
        }

        private void FacebookLogin(object sender, RoutedEventArgs e)
        {
            webBrowser.Navigate($"https://www.facebook.com/v3.2/dialog/oauth?client_id=230967437849830&redirect_uri=https://polypaint.me/signin-facebook&response_type=token");
        }
    }
}
