using PolyPaint.Strokes;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for EditLineTitleWindow.xaml
    /// </summary>
    public partial class EditLineTitleWindow : Window
    {
        StrokeBuilder strokeBuilder = new StrokeBuilder();
        VueModele viewModel { get; set; }
        public InkCanvas SurfaceDessin { get; set; }
        public EditLineTitleWindow(AbstractLineStroke stroke, InkCanvas surfaceDessin, VueModele vm)
        {
            DataContext = stroke;
            SurfaceDessin = surfaceDessin;
            InitializeComponent();
            Loaded += (sender, e) => titleTextBox.Focus();
            viewModel = vm;
        }

        private void Ok_ClickAsync(object sender, RoutedEventArgs e)
        {
            var drawViewModel = strokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection() { (Stroke)DataContext });
            Close();
            (DataContext as ICanvasable).Redraw();
            viewModel.CollaborationClient.CollaborativeDrawAsync(drawViewModel);
        }
    }
}
