using PolyPaint.Modeles;
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
    /// Logique d'interaction pour UploadToCloud.xaml
    /// </summary>
    public partial class UploadToCloud : Window
    {
        public ChatClient ChatClient;

        public UploadToCloud(ChatClient chatClient)
        {
            InitializeComponent();
            ChatClient = chatClient;
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            var canvas = new SaveableCanvas(Guid.NewGuid().ToString(), nameTextBox.Text, "[]", new byte[0], visibilityComboBox.Text, passwordTextBox.Password, Application.Current.Properties["username"].ToString(), 1000, 500);

            FenetreDessin fenetreDessin = new FenetreDessin(new List<Common.Collaboration.DrawViewModel>(), canvas, ChatClient);

            Application.Current.MainWindow = fenetreDessin;
            Close();
            fenetreDessin.Show();
            Close();
        }
    }
}
