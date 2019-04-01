using PolyPaint.Strokes;
using PolyPaint.Utilitaires;
using PolyPaint.VueModeles;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Ink;
using System.Windows.Input;

namespace PolyPaint.Vues
{
    /// <summary>
    /// Interaction logic for EditTitleWindow.xaml
    /// </summary>
    public partial class EditTitleWindow : Window
    {
        StrokeBuilder strokeBuilder = new StrokeBuilder();
        VueModele viewModel { get; set; }
        public InkCanvas SurfaceDessin { get; set; }
        public EditTitleWindow(AbstractShapeStroke stroke, InkCanvas surfaceDessin, VueModele vm)
        {
            DataContext = stroke;
            SurfaceDessin = surfaceDessin;
            InitializeComponent();
            Loaded += (sender, e) => titleTextBox.Focus();
            viewModel = vm;
        }

        private async void Ok_ClickAsync(object sender, RoutedEventArgs e)
        {
            var drawViewModel = strokeBuilder.GetDrawViewModelsFromStrokes(new StrokeCollection() { (Stroke)DataContext });
            Close();
            (DataContext as ICanvasable).Redraw();
            await viewModel.CollaborationClient.CollaborativeDrawAsync(drawViewModel);
        }
    }
}
