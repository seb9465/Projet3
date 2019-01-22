using PolyPaint.DataAccess.Contexts;

namespace PolyPaint.DataAccess.Services
{
    public static class DataSeeder
    {
        public static void Seed(PolyPaintContext polyPaintContext)
        {
           polyPaintContext.Database.EnsureCreated();
        }
    }
}
