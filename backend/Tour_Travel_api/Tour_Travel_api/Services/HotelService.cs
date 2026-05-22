using Microsoft.EntityFrameworkCore;
using TravelApp.Data;
using TravelApp.DTOs.Hotel;
using TravelApp.Helpers;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class HotelService
    {
        private readonly AppDbContext _context;
        private readonly NotificationService _notificationService;

        public HotelService(AppDbContext context, NotificationService notificationService)
        {
            _context = context;
            _notificationService = notificationService;
        }

        public void AddHotel(CreateHotelDto dto)
        {
            var hotel = new Hotel
            {
                Name = dto.Name,
                Location = dto.Location,
                Description = dto.Description,
                ImageUrl = dto.ImageUrl ?? "",
                Amenities = dto.Amenities,
                PricePerNight = dto.PricePerNight,
                AvailableRooms = dto.AvailableRooms,
                IsFeatured = dto.IsFeatured
            };
            _context.Hotels.Add(hotel);
            _context.SaveChanges();

            _context.Rooms.Add(new Room
            {
                HotelId = hotel.Id,
                Type = "Standard Room",
                Price = dto.PricePerNight,
                AvailableRooms = dto.AvailableRooms
            });
            _context.SaveChanges();
        }

        public List<Hotel> GetHotels() => _context.Hotels.ToList();

        public List<Hotel> GetFeaturedHotels() =>
            _context.Hotels.Where(h => h.IsFeatured).ToList();

        private async Task<Room> EnsureDefaultRoomAsync(Hotel hotel)
        {
            var room = await _context.Rooms.FirstOrDefaultAsync(r => r.HotelId == hotel.Id);
            if (room != null)
                return room;

            room = new Room
            {
                HotelId = hotel.Id,
                Type = "Standard Room",
                Price = hotel.PricePerNight,
                AvailableRooms = hotel.AvailableRooms
            };
            _context.Rooms.Add(room);
            await _context.SaveChangesAsync();
            return room;
        }

        public async Task BookHotel(int userId, BookHotelDto dto)
        {
            BookingValidation.ValidateQuantity(dto.RoomCount, "rooms");
            var nights = BookingValidation.ValidateHotelStay(dto.CheckIn, dto.CheckOut);

            var hotel = await _context.Hotels.FindAsync(dto.HotelId)
                ?? throw new Exception("Hotel not found");

            if (hotel.AvailableRooms < dto.RoomCount)
                throw new Exception($"Only {hotel.AvailableRooms} room(s) available.");

            var room = dto.RoomId > 0
                ? await _context.Rooms.FindAsync(dto.RoomId)
                : await _context.Rooms.FirstOrDefaultAsync(r => r.HotelId == dto.HotelId);

            if (room == null)
                room = await EnsureDefaultRoomAsync(hotel);

            if (room.AvailableRooms < dto.RoomCount)
                throw new Exception($"Only {room.AvailableRooms} room(s) available for {room.Type}.");
            var totalPrice = room.Price * dto.RoomCount * nights;

            hotel.AvailableRooms -= dto.RoomCount;
            room.AvailableRooms -= dto.RoomCount;

            var booking = new HotelBooking
            {
                UserId = userId,
                RoomId = room.Id,
                CheckIn = dto.CheckIn,
                CheckOut = dto.CheckOut,
                RoomCount = dto.RoomCount,
                TotalPrice = totalPrice,
                PaymentMethod = dto.PaymentMethod,
                TransactionId = dto.TransactionId,
                Status = "Confirmed"
            };

            _context.HotelBookings.Add(booking);
            await _context.SaveChangesAsync();

            try
            {
                await _notificationService.CreateNotificationAsync(userId, "Hotel Booked Successfully",
                    $"Your stay at {hotel.Name} ({room.Type}) — {dto.RoomCount} room(s). Check-in: {dto.CheckIn:yyyy-MM-dd}, Check-out: {dto.CheckOut:yyyy-MM-dd}. Total: ${totalPrice}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification error: {ex.Message}");
            }
        }
    }
}
