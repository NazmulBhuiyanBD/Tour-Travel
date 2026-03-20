using TravelApp.Data;
using TravelApp.DTOs.Hotel;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class HotelService
    {
        private readonly AppDbContext _context;

        public HotelService(AppDbContext context)
        {
            _context = context;
        }

        public void AddHotel(CreateHotelDto dto)
        {
            _context.Hotels.Add(new Hotel
            {
                Name = dto.Name,
                Location = dto.Location,
                Description = dto.Description
            });

            _context.SaveChanges();
        }
    }
}