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
            return _context.Flights
                .Where(x => x.From == from && x.To == to)
                .ToList();
        }
    }
}