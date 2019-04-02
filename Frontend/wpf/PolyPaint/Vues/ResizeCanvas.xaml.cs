using PolyPaint.VueModeles;
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
    public partial class ResizeCanvas : Window
    {
        public double CanvasHeight;
        public double CanvasWidth;

        public ResizeCanvas()
        {
            InitializeComponent();
            this.ShowDialog();
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            CanvasHeight = Convert.ToDouble(heightTextBox.Text);
            CanvasWidth = Convert.ToDouble(widthTextBox.Text);
            Close();
        }
    }
}
