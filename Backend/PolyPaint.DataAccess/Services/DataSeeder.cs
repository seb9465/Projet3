using PolyPaint.DataAccess.Contexts;

namespace PolyPaint.DataAccess.Services
{
    public static class DataSeeder
    {
        public async static void Seed(PolyPaintContext polyPaintContext)
        {
           await polyPaintContext.Database.EnsureCreatedAsync();
        }
    }
}
