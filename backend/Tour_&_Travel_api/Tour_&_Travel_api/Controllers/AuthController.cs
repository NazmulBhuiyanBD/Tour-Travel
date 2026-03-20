using Microsoft.AspNetCore.Mvc;
using TravelApp.Data;
using TravelApp.DTOs.Auth;
using TravelApp.Models;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly JwtService _jwt;

        public AuthController(AppDbContext context, JwtService jwt)
        {
            _context = context;
            _jwt = jwt;
        }

        [HttpPost("register")]
        public IActionResult Register(RegisterDto dto)
        {
            if (_context.Users.Any(x => x.Email == dto.Email))
                return BadRequest("Email exists");

            var user = new User
            {
                Name = dto.Name,
                Email = dto.Email,
                Password = PasswordHasher.Hash(dto.Password),
                Phone = dto.Phone
            };

            _context.Users.Add(user);
            _context.SaveChanges();

            return Ok("Registered");
        }

        [HttpPost("login")]
        public IActionResult Login(LoginDto dto)
        {
            var pass = PasswordHasher.Hash(dto.Password);

            var user = _context.Users
                .FirstOrDefault(x => x.Email == dto.Email && x.Password == pass);

            if (user == null) return Unauthorized();

            var token = _jwt.GenerateToken(user);

            return Ok(new { token, user.Name, user.Role });
        }
    }
}