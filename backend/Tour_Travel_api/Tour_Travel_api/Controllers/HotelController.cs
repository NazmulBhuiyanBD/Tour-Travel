using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.DTOs.Hotel;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HotelController : ControllerBase
    {
        private readonly HotelService _hotelService;

        public HotelController(HotelService hotelService)
        {
            _hotelService = hotelService;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public IActionResult Add(CreateHotelDto dto)
        {
            try
            {
                _hotelService.AddHotel(dto);
                return Ok(new { message = "Hotel added successfully" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] DateTime? checkIn, [FromQuery] DateTime? checkOut)
        {
            if (checkIn.HasValue && checkOut.HasValue)
            {
                try
                {
                    var hotels = await _hotelService.GetHotelsWithAvailabilityAsync(checkIn.Value, checkOut.Value);
                    return Ok(hotels);
                }
                catch (Exception ex)
                {
                    return BadRequest(new { message = ex.Message });
                }
            }
            return Ok(_hotelService.GetHotels());
        }

        [HttpGet("{hotelId}/availability")]
        public async Task<IActionResult> GetAvailability(int hotelId, [FromQuery] DateTime checkIn, [FromQuery] DateTime checkOut)
        {
            try
            {
                var availability = await _hotelService.GetRoomAvailabilityAsync(hotelId, checkIn, checkOut);
                return Ok(availability);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("featured")]
        public IActionResult GetFeatured()
        {
            return Ok(_hotelService.GetFeaturedHotels());
        }

        [Authorize]
        [HttpPost("book")]
        public async Task<IActionResult> Book(BookHotelDto dto)
        {
            try
            {
                var userId = GetUserId();
                await _hotelService.BookHotel(userId, dto);
                return Ok(new { message = "Hotel booked successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
