using System;
using System.Text.RegularExpressions;
using System.Windows;

namespace PolyPaint.Vues
{
    public partial class ResizeCanvas : Window
    {
        public double CanvasHeight;
        public double CanvasWidth;

        public ResizeCanvas(double width, double height)
        {
            InitializeComponent();
            heightTextBox.Text = height.ToString();
            widthTextBox.Text = width.ToString();
            ShowDialog();
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
