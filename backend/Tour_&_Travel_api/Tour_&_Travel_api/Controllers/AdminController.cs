using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TravelApp.Data;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("users")]
        public IActionResult Users() =>
            Ok(_context.Users.ToList());

        [HttpGet("dashboard")]
        public IActionResult Dashboard() => Ok(new
        {
            users = _context.Users.Count(),
            flights = _context.Flights.Count(),
            hotels = _context.Hotels.Count()
        });
    }
}