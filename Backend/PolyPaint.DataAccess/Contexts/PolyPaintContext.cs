using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PolyPaint.Core;

namespace PolyPaint.DataAccess.Contexts
{
    public class PolyPaintContext : IdentityDbContext<ApplicationUser>
    {
        public PolyPaintContext(DbContextOptions<PolyPaintContext> options)
            : base(options)
        {
        }
    }
}
