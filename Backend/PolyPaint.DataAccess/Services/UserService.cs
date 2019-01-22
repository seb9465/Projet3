using System;
using System.Collections.Generic;
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
        public UserService(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }

        public async Task<bool> Save(string userId, Canvas canvas)
        {
            ApplicationUser user = await _userManager.FindByIdAsync(userId);
            user.Canvas.Add(canvas);
            await _userManager.UpdateAsync(user);
            return true;
        }

        public async Task<List<Canvas>> GetAllCanvas(string userId)
        {
            ApplicationUser user = await _userManager.Users.Include(x => x.Canvas).SingleAsync(u => u.Id == userId);
            return user.Canvas;
        }
    }
}
