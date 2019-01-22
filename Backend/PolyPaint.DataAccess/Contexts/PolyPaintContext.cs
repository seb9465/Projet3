using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PolyPaint.Core;
using PolyPaint.Core.DbModels;

namespace PolyPaint.DataAccess.Contexts
{
    public class PolyPaintContext : IdentityDbContext<ApplicationUser>
    {
        public PolyPaintContext(DbContextOptions<PolyPaintContext> options)
            : base(options)
        {
        }
        public DbSet<Canvas> Canvas { get; set; }
    }
}
