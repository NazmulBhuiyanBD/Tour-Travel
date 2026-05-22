using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.DTOs.Flight;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FlightController : ControllerBase
    {
        private readonly FlightService _flightService;

        public FlightController(FlightService flightService)
        {
            _flightService = flightService;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        [HttpGet]
        public IActionResult GetAll()
        {
            return Ok(_flightService.Search(null, null));
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public IActionResult Add(CreateFlightDto dto)
        {
            _flightService.AddFlight(dto);
            return Ok(new { message = "Flight added safely" });
        }

        [HttpGet("search")]
        public IActionResult Search(string? from, string? to)
        {
            var result = _flightService.Search(from, to);
            return Ok(result);
        }

        [HttpGet("popular")]
        public IActionResult GetPopular()
        {
            return Ok(_flightService.GetPopularFlights());
        }

        [HttpGet("{id}/seat-classes")]
        public IActionResult GetSeatClasses(int id)
        {
            return Ok(_flightService.GetSeatClasses(id));
        }

        [Authorize]
        [HttpPost("book")]
        public async Task<IActionResult> Book(BookFlightDto dto)
        {
            try
            {
                var userId = GetUserId();
                await _flightService.BookFlight(userId, dto);
                return Ok(new { message = "Flight booked successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}