using System;
using System.Windows;
using System.Windows.Media;

namespace PolyPaint
{
    public static class Config
    {
        public static string URL = "https://polypaint.me";
        public static readonly int MIN_DISTANCE_ANCHORS = 10;
        public static readonly int MAX_CANVAS_WIDTH = 1200;
        public static readonly int MAX_CANVAS_HEIGHT = 1200;
        public static readonly FontFamily F_FAMILY = new FontFamily(new Uri("pack://application:,,,/"), "./Resources/#SF Pro Text Regular");
        public static readonly Typeface T_FACE = new Typeface(F_FAMILY, FontStyles.Normal, FontWeights.Normal, FontStretches.Normal);
    }
}
