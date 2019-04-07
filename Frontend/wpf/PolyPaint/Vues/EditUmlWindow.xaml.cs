using PolyPaint.Strokes;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for EditUmlWindow.xaml
    /// </summary>
    public partial class EditUmlWindow : Window
    {
        VueModele viewModel { get; set; }
        public InkCanvas SurfaceDessin { get; set; }
        public EditUmlWindow(UmlClassStroke stroke, InkCanvas surfaceDessin, VueModele vm)
        {
            DataContext = stroke;
            SurfaceDessin = surfaceDessin;
            InitializeComponent();
            Loaded += (sender, e) => titleTextBox.Focus();
            viewModel = vm;
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            var drawViewModel = StrokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection() { (Stroke)DataContext });
            Close();
            (DataContext as ICanvasable).Redraw();
            viewModel.CollaborationClient.CollaborativeDrawAsync(drawViewModel);
        }
    }
}
