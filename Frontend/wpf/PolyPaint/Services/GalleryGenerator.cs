using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using Microsoft.Win32;
using PolyPaint.Modeles;
using PolyPaint.Vues;

namespace PolyPaint
{
    public class GalleryGenerator
    {
        public static void CreateGalleryFromCloud(List<SaveableCanvas> strokes)
        {
            List<BitmapSource> bitmaps = ConvertStrokesToPNG(strokes);
            Gallery gallery = new Gallery(bitmaps);
            gallery.ShowDialog();
        }

        private static List<BitmapSource> ConvertStrokesToPNG(List<SaveableCanvas> strokes)
        {
            List<BitmapSource> bitmaps = new List<BitmapSource>();
            foreach(var canvas in strokes)
            {
                var bytes = Convert.FromBase64String(canvas.Base64Strokes);
                var bitmap = (BitmapSource)new ImageSourceConverter().ConvertFrom(bytes);
                bitmaps.Add(bitmap);
            }
            return bitmaps;
        }
    }
}