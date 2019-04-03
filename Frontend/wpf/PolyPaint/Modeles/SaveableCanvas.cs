namespace PolyPaint.Modeles
{
    public class SaveableCanvas
    {
        public SaveableCanvas(string canvasId, string name, string drawViewModels, byte[] image, string canvasVisibility, string canvasProtection, string canvasAutor, double canvasWidth, double canvasHeight)
        {
            CanvasId = canvasId;
            Name = name;
            DrawViewModels = drawViewModels;
            Image = image;
            CanvasVisibility = canvasVisibility;
            CanvasProtection = canvasProtection;
            CanvasAutor = canvasAutor;
            CanvasWidth = canvasWidth;
            CanvasHeight = canvasHeight;
        }
        public string CanvasId { get; set; }
        public string Name { get; set; }
        public string DrawViewModels { get; set; }
        public byte[] Image { get; set; }
        public string CanvasVisibility { get; set; }
        public string CanvasProtection { get; set; }
        public string CanvasAutor { get; set; }
        public double CanvasWidth { get; set; }
        public double CanvasHeight { get; set; }

    }
}
