﻿using System;
using System.ComponentModel.DataAnnotations;
using PolyPaint.Core.ViewModels;

namespace PolyPaint.Core.DbModels
{
    public class Canvas
    {
        [Key] public string CanvasId { get; set; }
        [Required] public string Name { get; set; }
        [Required] public string DrawViewModels { get; set; }
        [Required] public string Image { get; set; }
        [Required] public string canvasVisibility { get; set; }
        public string canvasAutor { get; set; }
        public string canvasProtection { get; set; }
        public string canvasPassword { get; set; }
        public double canvasWidth { get; set; } = 1000;
        public double canvasHeight { get; set; } = 500;

        public Canvas()
        {
        }
    }
}