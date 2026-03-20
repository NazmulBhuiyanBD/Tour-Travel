using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.Data;
using TravelApp.DTOs.Hotel;
using TravelApp.Models;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HotelController : ControllerBase
    {
        private readonly AppDbContext _context;

        public HotelController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public IActionResult Add(CreateHotelDto dto)
        {
            _context.Hotels.Add(new Hotel
            {
                Name = dto.Name,
                Location = dto.Location,
                Description = dto.Description
            });

            _context.SaveChanges();
            return Ok();
        }

        [HttpGet]
        public IActionResult Get() => Ok(_context.Hotels.ToList());

        [Authorize]
        [HttpPost("book")]
        public IActionResult Book(BookHotelDto dto)
        {
            var room = _context.Rooms.Find(dto.RoomId);

            room.AvailableRooms--;

            _context.HotelBookings.Add(new HotelBooking
            {
                UserId = GetUserId(),
                RoomId = dto.RoomId,
                CheckIn = dto.CheckIn,
                CheckOut = dto.CheckOut,
                TotalPrice = room.Price
            });

            _context.SaveChanges();
            return Ok();
        }
    }
}