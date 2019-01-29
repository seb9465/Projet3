using System;
using System.ComponentModel.DataAnnotations;
using PolyPaint.Core.ViewModels;

namespace PolyPaint.Core.DbModels
{
    public class Canvas
    {
        [Key] public string CanvasId { get; set; }
        [Required] public string Name { get; set; }
        [Required] public string Base64Strokes { get; set; }
        [Required] public string Base64Image { get; set; }

        public Canvas()
        {
        }
    }
}