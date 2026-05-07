using TravelApp.Data;
using TravelApp.DTOs.Flight;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class FlightService
    {
        private readonly AppDbContext _context;

        public FlightService(AppDbContext context)
        {
            _context = context;
        }

        public void AddFlight(CreateFlightDto dto)
        {
            var f = new Flight
            {
                Airline = dto.Airline,
                From = dto.From,
                To = dto.To,
                DepartureTime = dto.DepartureTime,
                ArrivalTime = dto.ArrivalTime,
                Price = dto.Price,
                AvailableSeats = dto.AvailableSeats
            };

            _context.Flights.Add(f);
            _context.SaveChanges();
        }

        public List<Flight> Search(string from, string to)
        {
            var query = _context.Flights.AsQueryable();

            if (!string.IsNullOrEmpty(from))
                query = query.Where(x => x.From.ToLower().Contains(from.ToLower()));

            if (!string.IsNullOrEmpty(to))
                query = query.Where(x => x.To.ToLower().Contains(to.ToLower()));

            return query.ToList();
        }

        public List<Flight> GetPopularFlights()
        {
            return _context.Flights.Where(f => f.IsPopular).ToList();
        }

        public void BookFlight(int userId, BookFlightDto dto)
        {
            var f = _context.Flights.Find(dto.FlightId);

            if (f == null)
                throw new Exception("Flight not found");

            if (f.AvailableSeats < dto.SeatCount)
                throw new Exception("Not enough seats available");

            f.AvailableSeats -= dto.SeatCount;

            _context.FlightBookings.Add(new FlightBooking
            {
                UserId = userId,
                FlightId = dto.FlightId,
                SeatCount = dto.SeatCount,
                TotalPrice = f.Price * dto.SeatCount,
                PaymentMethod = dto.PaymentMethod,
                TransactionId = dto.TransactionId
            });

            _context.SaveChanges();
        }
    }
}