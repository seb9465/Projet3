using Microsoft.AspNetCore.Identity;
using PolyPaint.Core;
using PolyPaint.Core.DbModels;
using PolyPaint.Core.ViewModels;
using PolyPaint.DataAccess.Contexts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
namespace PolyPaint.DataAccess.Services
{
    public class CanvasService
    {
        private readonly PolyPaintContext _context;
        public CanvasService(PolyPaintContext context)
        {
            _context = context;
        }
        public List<Canvas> GetAllCanvas()
        {
            return _context.Set<Canvas>().ToList();
        }

        public Canvas GetCanvasById(string canvasId)
        {
            return _context.Set<Canvas>().Where(x => x.CanvasId == canvasId).FirstOrDefault();
        }
    }
}
