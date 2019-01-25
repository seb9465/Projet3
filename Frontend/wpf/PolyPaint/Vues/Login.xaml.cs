using System.Windows;

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

        private void LoginBtn_Click(object sender, RoutedEventArgs e)
        {
            string username = usernameBox.Text;
            string password = passwordBox.Password;
            this.Content = register;
        }

        private void OfflineBtn_Click(object sender, RoutedEventArgs e)
        {
            /*          FenetreDessin main = new FenetreDessin();
                      App.Current.MainWindow = main;
                      this.Close();
                      main.Show();*/
        }
    }
}
