using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for WebBrowserWindow.xaml
    /// </summary>
    public partial class WebBrowserWindow : Window
    {
        public string Token { get; set; }
        public WebBrowserWindow()
        {
            InitializeComponent();
            Loaded += FacebookLogin;
            webBrowser.Navigated += CheckToken;
        }

        private void CheckToken(object sender, NavigationEventArgs e)
        {
            if (e.Uri.ToString().ToLower().StartsWith($"{Config.URL}/api/login/fb-callback"))
            {
                dynamic doc = webBrowser.Document;
                Token = doc.documentElement.LastChild.InnerHtml.Replace("<PRE>","");
                Token = Token.Replace("</PRE>", "");
                Close();
            }
        }

        private void FacebookLogin(object sender, RoutedEventArgs e)
        {
            webBrowser.Navigate($"{Config.URL}/api/login");
        }
    }
}
