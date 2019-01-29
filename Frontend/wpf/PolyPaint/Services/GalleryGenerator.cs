using System;
using System.Collections.Generic;
using PolyPaint.Modeles;
using PolyPaint.Vues;

namespace PolyPaint
{
    public class GalleryGenerator
    {
        public static void CreateGalleryFromCloud(List<SaveableCanvas> strokes)
        {
            Gallery gallery = new Gallery();
            gallery.ShowDialog();
        }
    }
}