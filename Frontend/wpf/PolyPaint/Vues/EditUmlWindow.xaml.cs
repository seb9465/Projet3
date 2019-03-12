using PolyPaint.Strokes;
using System.Windows;
using System.Windows.Controls;

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
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            Close();
            (DataContext as UmlClassStroke).RemoveFromCanvas();
            SurfaceDessin.Strokes.Add(DataContext as UmlClassStroke);
        }
    }
}
