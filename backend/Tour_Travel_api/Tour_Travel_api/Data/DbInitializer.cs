using TravelApp.Models;

namespace TravelApp.Data
{
    public static class DbInitializer
    {
        public static void Initialize(AppDbContext context)
        {
            context.Database.EnsureCreated();


        }
    }
}
