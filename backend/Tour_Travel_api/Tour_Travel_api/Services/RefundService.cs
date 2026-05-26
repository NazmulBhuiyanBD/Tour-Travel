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

        public async Task<bool> UpdateRefundStatusAsync(int id, string status, int refundPercentage, string? adminFeedback)
        {
            var request = await _context.RefundRequests.FirstOrDefaultAsync(r => r.Id == id);
            if (request == null) return false;

            request.Status = status;
            request.RefundPercentage = refundPercentage;
            request.AdminFeedback = adminFeedback;

            if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
            {
                decimal originalPrice = 0;
                if (string.Equals(request.ItemType, "Flight", StringComparison.OrdinalIgnoreCase))
                {
                    var booking = await _context.FlightBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                    originalPrice = booking?.TotalPrice ?? 0;
                }
                else if (string.Equals(request.ItemType, "Hotel", StringComparison.OrdinalIgnoreCase))
                {
                    var booking = await _context.HotelBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                    originalPrice = booking?.TotalPrice ?? 0;
                }
                else if (string.Equals(request.ItemType, "Tour", StringComparison.OrdinalIgnoreCase))
                {
                    var booking = await _context.TourBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                    originalPrice = booking?.TotalPrice ?? 0;
                }

                request.RefundAmount = originalPrice * (refundPercentage / 100.0m);

                await RestoreInventoryAsync(request);
                await SetBookingStatusAsync(request.ItemType, request.BookingId, "Refunded");
            }
            else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
            {
                request.RefundAmount = 0;
                await SetBookingStatusAsync(request.ItemType, request.BookingId, "Confirmed");
            }
            else
            {
                await SetBookingStatusAsync(request.ItemType, request.BookingId, "RefundPending");
            }

            await _context.SaveChangesAsync();

            try
            {
                string statusMsg = status.Equals("Approved", StringComparison.OrdinalIgnoreCase)
                    ? $"approved ({refundPercentage}% back: ৳{request.RefundAmount})"
                    : status.ToLower();

                await _notificationService.CreateNotificationAsync(request.UserId, $"Refund Request {status}",
                    $"Your refund request for {request.ItemType} Booking #{request.BookingId} has been {statusMsg}.");
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
                var booking = await _context.FlightBookings
                    .Include(b => b.Flight)
                    .FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) throw new Exception("Booking not found.");
                if (booking.UserId != request.UserId) throw new Exception("Unauthorized booking access.");
                if (booking.Flight == null) throw new Exception("Flight not found.");
                ValidateRefundWindow(booking.Status, booking.Flight.DepartureTime);
                request.BookingPrice = booking.TotalPrice;
            }
            else if (string.Equals(request.ItemType, "Hotel", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.HotelBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) throw new Exception("Booking not found.");
                if (booking.UserId != request.UserId) throw new Exception("Unauthorized booking access.");
                ValidateRefundWindow(booking.Status, booking.CheckIn);
                request.BookingPrice = booking.TotalPrice;
            }
            else if (string.Equals(request.ItemType, "Tour", StringComparison.OrdinalIgnoreCase))
            {
                var booking = await _context.TourBookings.FirstOrDefaultAsync(b => b.Id == request.BookingId);
                if (booking == null) throw new Exception("Booking not found.");
                if (booking.UserId != request.UserId) throw new Exception("Unauthorized booking access.");

                var tour = await _context.Tours.FirstOrDefaultAsync(t => t.Id == booking.TourId);
                if (tour == null) throw new Exception("Tour not found.");
                ValidateRefundWindow(booking.Status, tour.StartDate);
                request.BookingPrice = booking.TotalPrice > 0 ? booking.TotalPrice : tour.Price * booking.ParticipantCount;
            }
            else
            {
                throw new Exception("Invalid item type.");
            }
        }

        private static void ValidateRefundWindow(string status, DateTime serviceStartDate)
        {
            if (!status.Equals("Confirmed", StringComparison.OrdinalIgnoreCase))
                throw new Exception("Refund requests are only allowed for confirmed bookings.");

            if (serviceStartDate.Date <= DateTime.UtcNow.Date)
                throw new Exception("Refund requests are only allowed before the service start or check-in date.");
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
