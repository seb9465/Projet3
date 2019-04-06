using System.Windows;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for ActivateProtection.xaml
    /// </summary>
    public partial class ActivateProtection : Window
    {
        public string Password { get; set; } = "";
        public ActivateProtection()
        {
            InitializeComponent();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            Password = passwordTextBox.Password;
            Close();
        }
    }
}
