using TravelApp.Data;
using TravelApp.DTOs.Booking;

namespace TravelApp.Services
{
    public class BookingService
    {
        private readonly AppDbContext _context;

        public BookingService(AppDbContext context)
        {
            _context = context;
        }

        public List<BookingHistoryDto> GetUserHistory(int userId)
        {
            var history = new List<BookingHistoryDto>();
            var user = _context.Users.Find(userId);
            var userName = user?.Name ?? "Traveler";
            var now = DateTime.UtcNow;

            var flights = _context.FlightBookings
                .Where(x => x.UserId == userId)
                .Join(_context.Flights,
                    b => b.FlightId,
                    f => f.Id,
                    (b, f) => new BookingHistoryDto
                    {
                        Type = "Flight",
                        ReferenceId = b.Id,
                        ItemId = f.Id,
                        ReferenceNumber = $"FLIGHT-{b.Id:D6}",
                        DetailTitle = $"{f.Airline} ({f.From} to {f.To})",
                        Status = b.Status,
                        TotalPrice = b.TotalPrice,
                        BookingDate = f.DepartureTime,
                        ServiceEndDate = f.ArrivalTime,
                        Quantity = b.SeatCount,
                        SeatClass = b.SeatClass,
                        Airline = f.Airline,
                        From = f.From,
                        To = f.To,
                        ArrivalTime = f.ArrivalTime,
                        UserName = userName,
                        PaymentMethod = b.PaymentMethod,
                        TransactionId = b.TransactionId,
                        CanReview = b.Status == "Confirmed" && f.ArrivalTime <= now,
                        CanRefund = b.Status == "Confirmed" || b.Status == "RefundPending"
                    }).ToList();

            var hotels = _context.HotelBookings
                .Where(x => x.UserId == userId)
                .Join(_context.Rooms,
                    b => b.RoomId,
                    r => r.Id,
                    (b, r) => new { b, r })
                .Join(_context.Hotels,
                    br => br.r.HotelId,
                    h => h.Id,
                    (br, h) => new BookingHistoryDto
                    {
                        Type = "Hotel",
                        ReferenceId = br.b.Id,
                        ItemId = h.Id,
                        ReferenceNumber = $"HOTEL-{br.b.Id:D6}",
                        DetailTitle = $"{h.Name} ({br.r.Type})",
                        Status = br.b.Status,
                        TotalPrice = br.b.TotalPrice,
                        BookingDate = br.b.CheckIn,
                        CheckOutDate = br.b.CheckOut,
                        Quantity = br.b.RoomCount,
                        Location = h.Location,
                        ImageUrl = h.ImageUrl,
                        UserName = userName,
                        PaymentMethod = br.b.PaymentMethod,
                        TransactionId = br.b.TransactionId,
                        CanReview = br.b.Status == "Confirmed" && br.b.CheckIn <= now,
                        CanRefund = br.b.Status == "Confirmed" || br.b.Status == "RefundPending"
                    }).ToList();

            var tours = _context.TourBookings
                .Where(x => x.UserId == userId)
                .Join(_context.Tours,
                    b => b.TourId,
                    t => t.Id,
                    (b, t) => new BookingHistoryDto
                    {
                        Type = "Tour",
                        ReferenceId = b.Id,
                        ItemId = t.Id,
                        ReferenceNumber = $"TOUR-{b.Id:D6}",
                        DetailTitle = t.Title,
                        Status = b.Status,
                        TotalPrice = b.TotalPrice > 0 ? b.TotalPrice : t.Price * b.ParticipantCount,
                        BookingDate = t.StartDate,
                        ServiceEndDate = t.StartDate.AddDays(t.DurationDays),
                        Quantity = b.ParticipantCount,
                        UserName = userName,
                        PaymentMethod = b.PaymentMethod,
                        TransactionId = b.TransactionId,
                        CanReview = b.Status == "Confirmed" && t.StartDate.AddDays(t.DurationDays) <= now,
                        CanRefund = b.Status == "Confirmed" || b.Status == "RefundPending"
                    }).ToList();

            history.AddRange(flights);
            history.AddRange(hotels);
            history.AddRange(tours);

            return history.OrderByDescending(x => x.BookingDate).ToList();
        }
    }
}
