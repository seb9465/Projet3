using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PolyPaint.Core;
using PolyPaint.Core.DbModels;
using PolyPaint.Core.ViewModels;
using PolyPaint.DataAccess.Contexts;

namespace PolyPaint.DataAccess.Services
{
    public class UserService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly PolyPaintContext _ctx;
        public UserService(UserManager<ApplicationUser> userManager, PolyPaintContext ctx)
        {
            _userManager = userManager;
            _ctx = ctx;
        }

        public async Task<bool> Save(string userId, Canvas canvas)
        {
            ApplicationUser user = await _userManager.FindByIdAsync(userId);

            var existingCanvas = _ctx.Canvas.SingleOrDefault(x => x.CanvasId == canvas.CanvasId);

            if (existingCanvas != null)
            {
                existingCanvas.Image = canvas.Image;
                existingCanvas.canvasHeight = canvas.canvasHeight;
                existingCanvas.canvasWidth = canvas.canvasWidth;
                existingCanvas.canvasProtection = canvas.canvasProtection;
                existingCanvas.canvasPassword = canvas.canvasPassword;
                existingCanvas.canvasVisibility = canvas.canvasVisibility;
                existingCanvas.DrawViewModels = canvas.DrawViewModels;
                _ctx.Canvas.Update(existingCanvas);
            }
            else
            {
                canvas.canvasAutor = user.UserName;
                _ctx.Canvas.Add(canvas);
            }

            _ctx.SaveChanges();
            return true;
        }

        public async Task<List<Canvas>> GetAllCanvas(string userId)
        {
            ApplicationUser user = await _userManager.Users.Include(x => x.Canvas).SingleAsync(u => u.Id == userId);
            return user.Canvas;
        }

        public async Task<ApplicationUser> FindByIdAsync(string userId)
        {
            return await _userManager.Users.SingleAsync(u => u.Id == userId);
        }

        public bool TryGetUserId(ClaimsPrincipal user, out string userId)
        {
            userId = user.FindFirstValue(ClaimTypes.NameIdentifier);
            return userId != null;
        }

        public async Task<bool> LogoutUser(string userid)
        {
            ApplicationUser user = await FindByIdAsync(userid);
            user.IsLoggedIn = false;
            IdentityResult result = await _userManager.UpdateAsync(user);
            return result.Succeeded;
        }
    }
}
