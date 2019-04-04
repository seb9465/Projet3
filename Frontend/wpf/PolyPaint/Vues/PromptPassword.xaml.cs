using PolyPaint.Common.Collaboration;
using PolyPaint.Modeles;
using System.Collections.Generic;
using System.Windows;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for PromptPassword.xaml
    /// </summary>
    public partial class PromptPassword : Window
    {
        public string Password { get; set; }
        public SaveableCanvas Canvas { get; set; }
        public List<DrawViewModel> DrawViewModels { get; set; }
        public ChatClient ChatClient { get; set; }

        public PromptPassword(SaveableCanvas canvas, List<DrawViewModel> drawViewModels, ChatClient chatClient)
        {
            InitializeComponent();
            Canvas = canvas;
            DrawViewModels = drawViewModels;
            ChatClient = chatClient;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            Password = passwordTextBox.Password;

            if (Password == Canvas.CanvasProtection)
            {
                FenetreDessin fenetreDessin = new FenetreDessin(DrawViewModels, Canvas, ChatClient);
                Application.Current.MainWindow = fenetreDessin;
                Close();
                fenetreDessin.Show();
            }
            else
            {
                errorMessage.Visibility = Visibility.Visible;
            }
        }
    }
}
