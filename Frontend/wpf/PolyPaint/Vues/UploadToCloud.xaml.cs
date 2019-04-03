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
        public String CanvasVisibility;
        public String CanvasName;
        public String CanvasProtection;
        public String CanvasAutor;
        public ChatClient ChatClient;

        public UploadToCloud(ChatClient chatClient)
        {
            InitializeComponent();
            ChatClient = chatClient;
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            CanvasName = nameTextBox.Text;
            CanvasVisibility = visibilityComboBox.Text;
            CanvasProtection = passwordTextBox.Password;
            CanvasAutor = Application.Current.Properties["username"].ToString();

            FenetreDessin fenetreDessin = new FenetreDessin(new List<Common.Collaboration.DrawViewModel>(), ChatClient, CanvasName, 1000, 500)
            {
                canvasName = CanvasName,
                canvasVisibility = CanvasVisibility,
                canvasProtection = CanvasProtection,
                canvasAutor = CanvasAutor
            };

            Application.Current.MainWindow = fenetreDessin;
            Close();
            fenetreDessin.Show();
            Close();
        }
    }
}
