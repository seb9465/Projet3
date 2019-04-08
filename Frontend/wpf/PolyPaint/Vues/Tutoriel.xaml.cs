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
            switchPage();
        }

        private void previousPage_Click(object sender, RoutedEventArgs e)
        {
            page--;
            switchPage();
        }

        private void switchPage()
        {
            switch (page)
            {
                case 0:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/1.png", UriKind.Relative));
                    tutorialText.Text = "You are now in your personal profile that contains a gallery of public and private images";
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
                    nextPageButton.Visibility = Visibility.Visible;
                    //nextPageButton.Visibility = Visibility.Collapsed;
                    break;
                case 3:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/2-0.png", UriKind.Relative));
                    tutorialText.Text = "By clicking this button, the chat will open in an external window ";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 4:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/2-1.png", UriKind.Relative));
                    tutorialText.Text = "In the gallery, yu can go to a canvas by selecting it in the list or create a new one by clicking on the plus button";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 5:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/2-2.png", UriKind.Relative));
                    tutorialText.Text = "When creating a new canvas, you will be asked to chose a visibility." +
                        " A public canvas can be seen by every user in the gallery. A private canvas can only be seen by yourself "
                        + "You will also need to select a protection. A protected canvas will require a password for other user to access it";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 6:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/3.png", UriKind.Relative));
                    tutorialText.Text = "Here is the canvas editor.";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 7:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/4.png", UriKind.Relative));
                    tutorialText.Text = "You can insert element to the canvas by selecting it in the menu";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 8:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/5.png", UriKind.Relative));
                    tutorialText.Text = "You can insert a connection figure to the canvas by selecting it in the menu";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 9:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/6.png", UriKind.Relative));
                    tutorialText.Text = "You can change the style of an element via the left side menu";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 10:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/7.png", UriKind.Relative));
                    tutorialText.Text = "You can rotate an element via the left side menu";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Visible;
                    break;
                case 11:
                    tutorialImage.Source = new BitmapImage(new Uri(@"/Resources/tutorial/8.png", UriKind.Relative));
                    tutorialText.Text = "When you right click on the canvas, you can access thoses functionnality: Select all, invert selection, invert selecion colors and transform all ";
                    previousPageButton.Visibility = Visibility.Visible;
                    nextPageButton.Visibility = Visibility.Collapsed;
                    break;
                default:
                    break;
            }

        }
    }
}
