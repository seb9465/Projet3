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
using System.Windows.Shapes;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Logique d'interaction pour ImageProtection.xaml
    /// </summary>
    public partial class ImageProtection : Window
    {
        public String PasswordEntered;
        public ImageProtection()
        {
            InitializeComponent();
            this.ShowDialog();
        }

        private void Ok_click(object sender, RoutedEventArgs e)
        {
            PasswordEntered = passwordTextBox.Password;
            Close();
        }
    }
}
