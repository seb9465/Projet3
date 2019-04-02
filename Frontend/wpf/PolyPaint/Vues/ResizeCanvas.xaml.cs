using PolyPaint.VueModeles;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
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

        private void FieldsUpdate(object sender, RoutedEventArgs e)
        {
            if (!Regex.IsMatch(heightTextBox.Text, "^[0-9]*$") | !Regex.IsMatch(widthTextBox.Text, "^[0-9]*$") | string.IsNullOrWhiteSpace(widthTextBox.Text) | string.IsNullOrWhiteSpace(heightTextBox.Text))
            {
                OkButton.IsEnabled = false;
            }
            else
            {
                OkButton.IsEnabled = true;
            }
        }
    }
}
