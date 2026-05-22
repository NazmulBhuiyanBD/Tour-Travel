using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.Data;
using TravelApp.DTOs.User;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UserController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UserController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        [HttpGet("profile")]
        public IActionResult Profile()
        {
            var user = _context.Users.Find(GetUserId());
            if (user == null) return NotFound();
            if (!user.IsActive)
                return Unauthorized(new { error = "BannedUser" });
            return Ok(user);
        }

        [HttpPut("update")]
        public IActionResult Update(UpdateProfileDto dto)
        {
            var user = _context.Users.Find(GetUserId());
            
            if (user == null) return NotFound("User not found");

            user.Name = dto.Name;
            user.Phone = dto.Phone;
            user.Gender = dto.Gender;
            user.DateOfBirth = dto.DateOfBirth;
            user.Address = dto.Address;
            user.ProfilePicture = dto.ProfilePicture;

            _context.SaveChanges();
            return Ok("Updated");
        }

        [HttpPost("change-password")]
        public IActionResult Change(ChangePasswordDto dto)
        {
            var user = _context.Users.Find(GetUserId());

            if (user.Password != PasswordHasher.Hash(dto.OldPassword))
                return BadRequest("Wrong password");

            user.Password = PasswordHasher.Hash(dto.NewPassword);

            _context.SaveChanges();
            return Ok("Password changed");
        }
    }
}