using PolyPaint.Strokes;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for EditTitleWindow.xaml
    /// </summary>
    public partial class EditTitleWindow : Window
    {
        public InkCanvas SurfaceDessin { get; set; }
        public EditTitleWindow(AbstractStroke stroke, InkCanvas surfaceDessin)
        {
            DataContext = stroke;
            SurfaceDessin = surfaceDessin;
            InitializeComponent();
            Loaded += (sender, e) => titleTextBox.Focus();
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            Close();
            (DataContext as ICanvasable).RemoveFromCanvas();
            (DataContext as ICanvasable).AddToCanvas();
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
