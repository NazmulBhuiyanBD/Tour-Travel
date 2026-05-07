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

        public List<Hotel> GetHotels()
        {
            return _context.Hotels.ToList();
        }

        public List<Hotel> GetFeaturedHotels()
        {
            return _context.Hotels.Where(h => h.IsFeatured).ToList();
        }

        public void BookHotel(int userId, BookHotelDto dto)
        {
            Room? room = null;
            if (dto.RoomId > 0)
            {
                room = _context.Rooms.Find(dto.RoomId);
            }
            else
            {
                // Auto-pick the first available room for this hotel
                room = _context.Rooms.FirstOrDefault(r => r.HotelId == dto.HotelId && r.AvailableRooms > 0);
            }

            if (room == null)
                throw new Exception("No available rooms found for this request");

            if (room.AvailableRooms <= 0)
                throw new Exception("No available rooms");

            room.AvailableRooms--;

            _context.HotelBookings.Add(new HotelBooking
            {
                UserId = userId,
                RoomId = dto.RoomId,
                CheckIn = dto.CheckIn,
                CheckOut = dto.CheckOut,
                TotalPrice = room.Price,
                PaymentMethod = dto.PaymentMethod,
                TransactionId = dto.TransactionId
            });

            _context.SaveChanges();
        }
    }
}