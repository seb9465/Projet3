using System;
using System.Text.RegularExpressions;
using System.Windows;

namespace PolyPaint.Vues
{
    public partial class ResizeCanvas : Window
    {
        public double CanvasHeight;
        public double CanvasWidth;

        private double InitWidth { get; set; }
        private double InitHeight { get; set; }

        public ResizeCanvas(double width, double height)
        {
            InitializeComponent();
            InitWidth = width;
            InitHeight = height;
            heightTextBox.Text = height.ToString();
            widthTextBox.Text = width.ToString();
            ShowDialog();
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            CanvasHeight = heightTextBox.Text == "" ? InitHeight : Convert.ToDouble(heightTextBox.Text);
            CanvasWidth = widthTextBox.Text == "" ? InitWidth : Convert.ToDouble(widthTextBox.Text);
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
