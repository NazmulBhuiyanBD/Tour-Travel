using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.Data;
using TravelApp.DTOs.Flight;
using TravelApp.Models;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FlightController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FlightController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public IActionResult Add(CreateFlightDto dto)
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
            return Ok();
        }

        [HttpGet("search")]
        public IActionResult Search(string from, string to)
        {
            return Ok(_context.Flights
                .Where(x => x.From == from && x.To == to)
                .ToList());
        }

        [Authorize]
        [HttpPost("book")]
        public IActionResult Book(BookFlightDto dto)
        {
            var f = _context.Flights.Find(dto.FlightId);

            if (f.AvailableSeats < dto.SeatCount)
                return BadRequest("No seats");

            f.AvailableSeats -= dto.SeatCount;

            _context.FlightBookings.Add(new FlightBooking
            {
                UserId = GetUserId(),
                FlightId = dto.FlightId,
                SeatCount = dto.SeatCount,
                TotalPrice = f.Price * dto.SeatCount
            });

            _context.SaveChanges();
            return Ok();
        }
    }
}