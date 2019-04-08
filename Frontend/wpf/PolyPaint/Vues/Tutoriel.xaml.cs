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
    /// Logique d'interaction pour Tutoriel.xaml
    /// </summary>
    public partial class Tutoriel : Window
    {

        int page = 0;
        public Tutoriel()
        {
            InitializeComponent();
            this.ShowDialog();
        }

        private void nextPage_Click(object sender, RoutedEventArgs e)
        {
            page++;
            switch (page)
            {
                case 1:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/capture.png", UriKind.Relative));
                    tutorialText.Text = "test test test test test test test test test test test test ";
                    break;
                case 2:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/cloud.png", UriKind.Relative));
                    tutorialText.Text = "test test test test";
                    nextPageButton.Visibility = Visibility.Collapsed;
                    break;
                default:
                    break;
            }
        }
    }
}
