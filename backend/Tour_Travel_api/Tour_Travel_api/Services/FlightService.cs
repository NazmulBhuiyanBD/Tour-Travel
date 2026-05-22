using Microsoft.EntityFrameworkCore;
using TravelApp.Data;
using TravelApp.DTOs.Flight;
using TravelApp.Helpers;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class FlightService
    {
        private readonly AppDbContext _context;
        private readonly NotificationService _notificationService;

        public FlightService(AppDbContext context, NotificationService notificationService)
        {
            _context = context;
            _notificationService = notificationService;
        }

        public void AddFlight(CreateFlightDto dto)
        {
            var seatClasses = dto.SeatClasses?.Where(s => s.AvailableSeats > 0).ToList();
            var totalSeats = seatClasses?.Sum(s => s.AvailableSeats) ?? dto.AvailableSeats;
            var minPrice = seatClasses?.Min(s => s.Price) ?? dto.Price;

            var f = new Flight
            {
                Airline = dto.Airline,
                From = dto.From,
                To = dto.To,
                DepartureTime = dto.DepartureTime,
                ArrivalTime = dto.ArrivalTime,
                Price = minPrice,
                AvailableSeats = totalSeats,
                IsPopular = dto.IsPopular
            };

            _context.Flights.Add(f);
            _context.SaveChanges();

            if (seatClasses != null && seatClasses.Count > 0)
            {
                foreach (var sc in seatClasses)
                {
                    _context.FlightSeatClasses.Add(new FlightSeatClass
                    {
                        FlightId = f.Id,
                        ClassName = sc.ClassName,
                        AvailableSeats = sc.AvailableSeats,
                        Price = sc.Price
                    });
                }
            }
            else
            {
                _context.FlightSeatClasses.Add(new FlightSeatClass
                {
                    FlightId = f.Id,
                    ClassName = "Economy",
                    AvailableSeats = dto.AvailableSeats,
                    Price = dto.Price
                });
            }

            _context.SaveChanges();
        }

        public static void SyncFlightTotals(Flight flight, IEnumerable<FlightSeatClass> classes)
        {
            flight.AvailableSeats = classes.Sum(c => c.AvailableSeats);
            flight.Price = classes.Any() ? classes.Min(c => c.Price) : flight.Price;
        }

        public List<Flight> Search(string? from, string? to)
        {
            var query = _context.Flights
                .Include(f => f.SeatClasses)
                .AsQueryable();

            if (!string.IsNullOrEmpty(from))
                query = query.Where(x => x.From.ToLower().Contains(from.ToLower()));

            if (!string.IsNullOrEmpty(to))
                query = query.Where(x => x.To.ToLower().Contains(to.ToLower()));

            return query.ToList();
        }

        public List<Flight> GetPopularFlights() =>
            _context.Flights.Include(f => f.SeatClasses).Where(f => f.IsPopular).ToList();

        public List<FlightSeatClass> GetSeatClasses(int flightId) =>
            _context.FlightSeatClasses.Where(s => s.FlightId == flightId).ToList();

        public async Task BookFlight(int userId, BookFlightDto dto)
        {
            BookingValidation.ValidateQuantity(dto.SeatCount, "seats");

            var f = await _context.Flights
                .Include(x => x.SeatClasses)
                .FirstOrDefaultAsync(x => x.Id == dto.FlightId)
                ?? throw new Exception("Flight not found");

            var seatClass = f.SeatClasses.FirstOrDefault(s =>
                s.ClassName.Equals(dto.SeatClass, StringComparison.OrdinalIgnoreCase));

            if (seatClass == null)
                throw new Exception($"Seat class '{dto.SeatClass}' is not available on this flight.");

            if (seatClass.AvailableSeats < dto.SeatCount)
                throw new Exception($"Only {seatClass.AvailableSeats} seat(s) left in {seatClass.ClassName}.");

            seatClass.AvailableSeats -= dto.SeatCount;
            SyncFlightTotals(f, f.SeatClasses);

            var totalPrice = seatClass.Price * dto.SeatCount;

            _context.FlightBookings.Add(new FlightBooking
            {
                UserId = userId,
                FlightId = dto.FlightId,
                SeatCount = dto.SeatCount,
                SeatClass = seatClass.ClassName,
                TotalPrice = totalPrice,
                PaymentMethod = dto.PaymentMethod,
                TransactionId = dto.TransactionId,
                Status = "Confirmed",
                BookingDate = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();

            try
            {
                await _notificationService.CreateNotificationAsync(userId, "Flight Booked Successfully",
                    $"Flight {f.From} → {f.To} ({f.Airline}), {dto.SeatCount} × {seatClass.ClassName}. Total: ${totalPrice}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification error: {ex.Message}");
            }
        }

        public void UpsertSeatClasses(int flightId, List<FlightSeatClassDto>? seatClasses)
        {
            if (seatClasses == null || seatClasses.Count == 0) return;

            var existing = _context.FlightSeatClasses.Where(s => s.FlightId == flightId).ToList();
            _context.FlightSeatClasses.RemoveRange(existing);

            foreach (var sc in seatClasses)
            {
                _context.FlightSeatClasses.Add(new FlightSeatClass
                {
                    FlightId = flightId,
                    ClassName = sc.ClassName,
                    AvailableSeats = sc.AvailableSeats,
                    Price = sc.Price
                });
            }

            var flight = _context.Flights.Find(flightId);
            if (flight != null)
            {
                var updated = _context.FlightSeatClasses.Where(s => s.FlightId == flightId).ToList();
                SyncFlightTotals(flight, updated);
            }
        }
    }
}
