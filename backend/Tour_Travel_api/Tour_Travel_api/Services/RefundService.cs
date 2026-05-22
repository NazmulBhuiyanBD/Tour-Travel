using Microsoft.EntityFrameworkCore;
using TravelApp.Data;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class RefundService
    {
        private readonly AppDbContext _context;
        private readonly NotificationService _notificationService;

        public RefundService(AppDbContext context, NotificationService notificationService)
        {
            _context = context;
            _notificationService = notificationService;
        }

        public async Task<RefundRequest> CreateRefundRequestAsync(RefundRequest request)
        {
            var existingPending = await _context.RefundRequests.AnyAsync(r =>
                r.BookingId == request.BookingId &&
                r.ItemType == request.ItemType &&
                r.Status == "Pending");

            if (existingPending)
                throw new Exception("A refund request is already pending for this booking.");

            await ValidateBookingOwnershipAsync(request);

            request.Status = "Pending";
            request.RequestedAt = DateTime.UtcNow;
            _context.RefundRequests.Add(request);

            await SetBookingStatusAsync(request.ItemType, request.BookingId, "RefundPending");
            await _context.SaveChangesAsync();

            try
            {
                await _notificationService.CreateNotificationAsync(request.UserId, "Refund Requested",
                    $"Your refund request for {request.ItemType} Booking #{request.BookingId} has been submitted.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification error: {ex.Message}");
            }

            return request;
        }

        public async Task<List<RefundRequest>> GetUserRefundRequestsAsync(int userId) =>
            await _context.RefundRequests
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.RequestedAt)
                .ToListAsync();

        public async Task<List<RefundRequest>> GetAllRefundRequestsAsync() =>
            await _context.RefundRequests
                .OrderByDescending(r => r.RequestedAt)
                .ToListAsync();

        public async Task<bool> UpdateRefundStatusAsync(int id, string status)
        {
            var request = await _context.RefundRequests.FirstOrDefaultAsync(r => r.Id == id);
            if (request == null) return false;

            request.Status = status;

            if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
            {
                await RestoreInventoryAsync(request);
                await SetBookingStatusAsync(request.ItemType, request.BookingId, "Refunded");
            }
            else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
            {
                await SetBookingStatusAsync(request.ItemType, request.BookingId, "Confirmed");
            }
            else
            {
                await SetBookingStatusAsync(request.ItemType, request.BookingId, "RefundPending");
            }

            await _context.SaveChangesAsync();

            try
            {
                await _notificationService.CreateNotificationAsync(request.UserId, $"Refund Request {status}",
                    $"Your refund request for {request.ItemType} Booking #{request.BookingId} has been {status.ToLower()}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification error: {ex.Message}");
            }

            return true;
        }

        private async Task ValidateBookingOwnershipAsync(RefundRequest request)
        {
            if (string.Equals(request.ItemType, "Flight", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.FlightBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) throw new Exception("Booking not found.");
                if (booking.UserId != request.UserId) throw new Exception("Unauthorized booking access.");
                if (booking.Status is "Refunded" or "Cancelled")
                    throw new Exception("This booking is already cancelled or refunded.");
            }
            else if (string.Equals(request.ItemType, "Hotel", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.HotelBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) throw new Exception("Booking not found.");
                if (booking.UserId != request.UserId) throw new Exception("Unauthorized booking access.");
                if (booking.Status is "Refunded" or "Cancelled")
                    throw new Exception("This booking is already cancelled or refunded.");
            }
            else if (string.Equals(request.ItemType, "Tour", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.TourBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) throw new Exception("Booking not found.");
                if (booking.UserId != request.UserId) throw new Exception("Unauthorized booking access.");
                if (booking.Status is "Refunded" or "Cancelled")
                    throw new Exception("This booking is already cancelled or refunded.");
            }
            else
            {
                throw new Exception("Invalid item type.");
            }
        }

        private async Task SetBookingStatusAsync(string itemType, int bookingId, string status)
        {
            if (string.Equals(itemType, "Flight", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.FlightBookings.FirstOrDefaultAsync(b => b.Id == bookingId);
                if (booking != null) booking.Status = status;
            }
            else if (string.Equals(itemType, "Hotel", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.HotelBookings.FirstOrDefaultAsync(b => b.Id == bookingId);
                if (booking != null) booking.Status = status;
            }
            else if (string.Equals(itemType, "Tour", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.TourBookings.FirstOrDefaultAsync(b => b.Id == bookingId);
                if (booking != null) booking.Status = status;
            }
        }

        private async Task RestoreInventoryAsync(RefundRequest request)
        {
            if (string.Equals(request.ItemType, "Flight", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.FlightBookings
                    .Include(b => b.Flight)
                    .ThenInclude(f => f.SeatClasses)
                    .FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) return;

                var seatClass = booking.Flight.SeatClasses.FirstOrDefault(s =>
                    s.ClassName.Equals(booking.SeatClass, StringComparison.OrdinalIgnoreCase));
                if (seatClass != null)
                {
                    seatClass.AvailableSeats += booking.SeatCount;
                    FlightService.SyncFlightTotals(booking.Flight, booking.Flight.SeatClasses);
                }
            }
            else if (string.Equals(request.ItemType, "Hotel", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.HotelBookings
                    .Include(b => b.Room)
                    .FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking?.Room == null) return;

                booking.Room.AvailableRooms += booking.RoomCount;
                var hotel = await _context.Hotels.FindAsync(booking.Room.HotelId);
                if (hotel != null) hotel.AvailableRooms += booking.RoomCount;
            }
            else if (string.Equals(request.ItemType, "Tour", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.TourBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) return;

                var tour = await _context.Tours.FindAsync(booking.TourId);
                if (tour != null) tour.Vacancy += booking.ParticipantCount;
            }
        }
    }
}
