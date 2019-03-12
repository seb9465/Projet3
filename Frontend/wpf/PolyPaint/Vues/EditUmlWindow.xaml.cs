using PolyPaint.Strokes;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for EditUmlWindow.xaml
    /// </summary>
    public partial class EditUmlWindow : Window
    {
        public InkCanvas SurfaceDessin { get; set; }
        public EditUmlWindow(UmlClassStroke stroke, InkCanvas surfaceDessin)
        {
            DataContext = stroke;
            SurfaceDessin = surfaceDessin;
            InitializeComponent();
            Loaded += (sender, e) => titleTextBox.Focus();
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            Close();
            (DataContext as UmlClassStroke).RemoveFromCanvas();
            (DataContext as UmlClassStroke).AddToCanvas();
        }

        private void EnterKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                Ok_Click(sender, e);
            }
        }
    }
}
