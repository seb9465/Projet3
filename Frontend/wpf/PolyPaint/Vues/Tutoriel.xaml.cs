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
                case 0:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/1.png", UriKind.Relative));
                    tutorialText.Text = " Here is your personal profile that contains a gallery of public and private images";
                    previousPageButton.Visibility = Visibility.Collapsed;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 1:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/1-0.png", UriKind.Relative));
                    tutorialText.Text = "you can access the chat via the right side menu";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 2: //CELUI QUI ETAIT LE DERNIER
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/2.png", UriKind.Relative));
                    tutorialText.Text = "You can connect to a chanel by clicking the connected/disconnected button. You can change the visible channel by selecting one of the radio button ";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Collapsed;
                    break;
                case 3:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/2-0.png", UriKind.Relative));
                    tutorialText.Text = "By clicking this button, the chat will open in an external window ";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Collapsed;
                    break;
                case 4:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/2-1.png", UriKind.Relative));
                    tutorialText.Text = "In the gallery, yu can go to a canvas by selecting it in the list or create a new one by clicking on the plus button";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Collapsed;
                    break;
                case 5:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/2-1.png", UriKind.Relative));
                    tutorialText.Text = "When creating a new canvas,";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Collapsed;
                    break;
                default:
                    break;
            }
        }

        private void previousPage_Click(object sender, RoutedEventArgs e)
        {
            page--;
           
        }
    }
}
