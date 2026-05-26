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
            if (dto.PricePerNight <= 0)
                throw new ArgumentException("Hotel price must be greater than zero.");
            if (dto.AvailableRooms <= 0)
                throw new ArgumentException("Available rooms must be greater than zero.");

            var hotel = new Hotel
            {
                Name = dto.Name,
                Location = dto.Location,
                Description = dto.Description,
                ImageUrl = dto.ImageUrl ?? "",
                Amenities = dto.Amenities,
                PricePerNight = dto.PricePerNight,
                AvailableRooms = dto.AvailableRooms,
                IsFeatured = dto.IsFeatured,
                ContactInfo = dto.ContactInfo ?? ""
            };
            _context.Hotels.Add(hotel);
            _context.SaveChanges();

            _context.Rooms.Add(new Room
            {
                HotelId = hotel.Id,
                Type = dto.RoomType,
                BedType = dto.BedType,
                ViewType = dto.ViewType,
                IsAc = dto.IsAc,
                Price = dto.PricePerNight,
                AvailableRooms = dto.AvailableRooms
            });
            _context.SaveChanges();
        }

        public List<Hotel> GetHotels() => _context.Hotels.Include(h => h.Rooms).ToList();

        public List<Hotel> GetFeaturedHotels() =>
            _context.Hotels.Include(h => h.Rooms).Where(h => h.IsFeatured).ToList();

        private async Task<Room> EnsureDefaultRoomAsync(Hotel hotel)
        {
            var room = await _context.Rooms.FirstOrDefaultAsync(r => r.HotelId == hotel.Id);
            if (room != null)
                return room;

            room = new Room
            {
                HotelId = hotel.Id,
                Type = "Standard Room",
                BedType = "King Bed",
                ViewType = "City View",
                IsAc = true,
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

            var room = dto.RoomId > 0
                ? await _context.Rooms.FindAsync(dto.RoomId)
                : await _context.Rooms.FirstOrDefaultAsync(r => r.HotelId == dto.HotelId);

            if (room == null)
                room = await EnsureDefaultRoomAsync(hotel);

            var availableRooms = await GetAvailableRoomCountAsync(room.Id, dto.CheckIn, dto.CheckOut);
            if (availableRooms < dto.RoomCount)
                throw new Exception($"Only {availableRooms} room(s) available for {room.Type} on the selected dates.");
            var totalPrice = room.Price * dto.RoomCount * nights;

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
                    $"Your stay at {hotel.Name} ({room.Type}) — {dto.RoomCount} room(s). Check-in: {dto.CheckIn:yyyy-MM-dd}, Check-out: {dto.CheckOut:yyyy-MM-dd}. Total: ৳{totalPrice}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification error: {ex.Message}");
            }
        }

        public async Task<List<object>> GetRoomAvailabilityAsync(int hotelId, DateTime checkIn, DateTime checkOut)
        {
            BookingValidation.ValidateHotelStay(checkIn, checkOut);

            var hotel = await _context.Hotels.FindAsync(hotelId)
                ?? throw new Exception("Hotel not found");

            var rooms = await _context.Rooms.Where(r => r.HotelId == hotelId).ToListAsync();
            if (rooms.Count == 0)
            {
                rooms.Add(await EnsureDefaultRoomAsync(hotel));
            }

            var availability = new List<object>();
            foreach (var room in rooms)
            {
                var availableRooms = await GetAvailableRoomCountAsync(room.Id, checkIn, checkOut);
                availability.Add(new
                {
                    room.Id,
                    room.HotelId,
                    room.Type,
                    room.BedType,
                    room.ViewType,
                    room.IsAc,
                    room.Price,
                    TotalRooms = room.AvailableRooms,
                    AvailableRooms = availableRooms
                });
            }

            return availability;
        }

        private async Task<int> GetAvailableRoomCountAsync(int roomId, DateTime checkIn, DateTime checkOut)
        {
            var room = await _context.Rooms.FindAsync(roomId)
                ?? throw new Exception("Room not found");

            var bookedRooms = await _context.HotelBookings
                .Where(b => b.RoomId == roomId
                    && (b.Status == "Confirmed" || b.Status == "RefundPending")
                    && b.CheckIn < checkOut
                    && checkIn < b.CheckOut)
                .SumAsync(b => b.RoomCount);

            return Math.Max(room.AvailableRooms - bookedRooms, 0);
        }

        public async Task<List<object>> GetHotelsWithAvailabilityAsync(DateTime checkIn, DateTime checkOut)
        {
            BookingValidation.ValidateHotelStay(checkIn, checkOut);

            var hotels = await _context.Hotels
                .Include(h => h.Rooms)
                .ToListAsync();

            var result = new List<object>();

            foreach (var hotel in hotels)
            {
                var availableRoomsCount = 0;
                var minPrice = decimal.MaxValue;

                foreach (var room in hotel.Rooms)
                {
                    var available = await GetAvailableRoomCountAsync(room.Id, checkIn, checkOut);
                    if (available > 0)
                    {
                        availableRoomsCount += available;
                        if (room.Price < minPrice)
                        {
                            minPrice = room.Price;
                        }
                    }
                }

                if (availableRoomsCount > 0)
                {
                    result.Add(new
                    {
                        hotel.Id,
                        hotel.Name,
                        hotel.Location,
                        hotel.Description,
                        hotel.Rating,
                        hotel.ImageUrl,
                        hotel.GalleryImages,
                        hotel.Amenities,
                        PricePerNight = minPrice,
                        AvailableRooms = availableRoomsCount,
                        hotel.IsFeatured,
                        hotel.ContactInfo,
                        Rooms = hotel.Rooms.Select(r => new
                        {
                            r.Id,
                            r.HotelId,
                            r.Type,
                            r.BedType,
                            r.ViewType,
                            r.IsAc,
                            r.Price,
                            r.AvailableRooms
                        }).ToList()
                    });
                }
            }

            return result;
        }
    }
}
