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
    /// Logique d'interaction pour UploadToCloud.xaml
    /// </summary>
    public partial class UploadToCloud : Window
    {
        public String CanvasVisibility;
        public String CanvasName;
        public String CanvasProtection;
        public UploadToCloud()
        {
            InitializeComponent();
            this.ShowDialog();
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            CanvasName = nameTextBox.Text;
            CanvasVisibility = visibilityComboBox.Text;
            CanvasProtection = passwordTextBox.Password;
            Close();
        }
    }

    
}
