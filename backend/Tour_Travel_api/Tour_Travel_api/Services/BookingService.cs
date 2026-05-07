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

            var flights = _context.FlightBookings
                .Where(x => x.UserId == userId)
                .Join(_context.Flights,
                    b => b.FlightId,
                    f => f.Id,
                    (b, f) => new BookingHistoryDto
                    {
                        Type = "Flight",
                        ReferenceId = b.Id,
                        ReferenceNumber = $"FLIGHT-{b.Id:D6}",
                        DetailTitle = $"{f.Airline} ({f.From} to {f.To})",
                        Status = "Confirmed",
                        TotalPrice = b.TotalPrice,
                        BookingDate = f.DepartureTime,
                        Airline = f.Airline,
                        From = f.From,
                        To = f.To,
                        ArrivalTime = f.ArrivalTime
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
                        ReferenceNumber = $"HOTEL-{br.b.Id:D6}",
                        DetailTitle = $"{h.Name} ({br.r.Type})",
                        Status = "Confirmed",
                        TotalPrice = br.b.TotalPrice,
                        BookingDate = br.b.CheckIn,
                        Location = h.Location,
                        ImageUrl = h.ImageUrl
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
                        ReferenceNumber = $"TOUR-{b.Id:D6}",
                        DetailTitle = t.Title,
                        Status = b.Status,
                        TotalPrice = t.Price,
                        BookingDate = b.BookingDate
                    }).ToList();



            history.AddRange(flights);
            history.AddRange(hotels);
            history.AddRange(tours);


            return history.OrderByDescending(x => x.BookingDate).ToList();
        }
    }
}
