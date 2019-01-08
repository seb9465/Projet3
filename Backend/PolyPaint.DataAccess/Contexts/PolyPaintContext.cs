using Microsoft.EntityFrameworkCore;

namespace PolyPaint.DataAccess.Contexts
{
    public class PolyPaintContext : DbContext
    {
        public PolyPaintContext(DbContextOptions<PolyPaintContext> options)
            : base(options)
        {
        }
    }
}
