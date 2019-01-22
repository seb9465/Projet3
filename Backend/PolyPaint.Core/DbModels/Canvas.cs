using System;
using System.ComponentModel.DataAnnotations;

namespace PolyPaint.Core.DbModels
{
    public class Canvas
    {
        public ApplicationUser ApplicationUser{get; set;}
        [Key] public string CanvasId { get; set; }
        [Required] public string Name { get; set; }
        [Required] public string Base64Strokes { get; set; }

        public Canvas()
        {
        }
    }
}