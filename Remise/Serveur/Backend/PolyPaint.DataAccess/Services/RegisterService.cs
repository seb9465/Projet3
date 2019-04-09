using Microsoft.AspNetCore.Identity;
using PolyPaint.Core;
using PolyPaint.DataAccess.Contexts;
using System.Threading.Tasks;

namespace PolyPaint.DataAccess.Services
{
    public class RegisterService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly PolyPaintContext _context;
        public RegisterService(UserManager<ApplicationUser> userManager, PolyPaintContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        public async Task<IdentityResult> RegisterNewUserAsync(ApplicationUser user, string password)
        {
            IdentityResult creation = await _userManager.CreateAsync(user, password);
            if (creation.Succeeded)
            {
                await _context.SaveChangesAsync();
            }
            return creation;
        }
    }
}
