using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.DTOs.Tour;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TourController : ControllerBase
    {
        private readonly TourService _tourService;

        public TourController(TourService tourService)
        {
            _tourService = tourService;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public IActionResult Add(CreateTourDto dto)
        {
            _tourService.AddTour(dto);
            return Ok(new { message = "Tour added successfully" });
        }

        [HttpGet]
        public IActionResult Get()
        {
            return Ok(_tourService.GetTours());
        }

        [HttpGet("top")]
        public IActionResult GetTop()
        {
            return Ok(_tourService.GetTopDestinations());
        }

        [Authorize]
        [HttpPost("book")]
        public async Task<IActionResult> Book(BookTourDto dto)
        {
            try
            {
                var userId = GetUserId();
                await _tourService.BookTour(userId, dto);
                return Ok(new { message = "Tour booked successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
