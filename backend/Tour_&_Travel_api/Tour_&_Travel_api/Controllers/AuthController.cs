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
        private readonly IEmailService _emailService;

        public AuthController(AppDbContext context, JwtService jwt, IEmailService emailService)
        {
            _context = context;
            _jwt = jwt;
            _emailService = emailService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterDto dto)
        {
            if (_context.Users.Any(x => x.Email.ToLower() == dto.Email.ToLower()))
                return BadRequest(new { error = "Email already exists" });

            var token = new Random().Next(100000, 999999).ToString();

            var user = new User
            {
                Name = dto.Name,
                Email = dto.Email,
                Password = PasswordHasher.Hash(dto.Password),
                Phone = dto.Phone,
                EmailConfirmationToken = token,
                IsEmailConfirmed = false
            };

            _context.Users.Add(user);
            _context.SaveChanges();

            await _emailService.SendEmailAsync(user.Email, "Confirm your email", $"Your confirmation code is: <b>{token}</b>");

            return Ok(new { message = "Registered successfully. Please check your email for confirmation code." });
        }

        [HttpPost("login")]
        public IActionResult Login(LoginDto dto)
        {
            var pass = PasswordHasher.Hash(dto.Password);

            var user = _context.Users
                .FirstOrDefault(x => x.Email.ToLower() == dto.Email.ToLower() && x.Password == pass);

            if (user == null) 
                return Unauthorized(new { error = "Invalid email or password" });

            if (!user.IsEmailConfirmed)
                return BadRequest(new { error = "EmailNotConfirmed" });

            var userToken = _jwt.GenerateToken(user);
            return Ok(new 
            { 
                token = userToken, 
                userName = user.Name, 
                email = user.Email,
                userId = user.Id.ToString(),
                role = user.Role 
            });
        }
        [HttpPost("admin-login")]
        public IActionResult AdminLogin(LoginDto dto)
        {
            var pass = PasswordHasher.Hash(dto.Password);

            var admin = _context.Admins
                .FirstOrDefault(x => x.Email.ToLower() == dto.Email.ToLower() && x.Password == pass);

            if (admin != null)
            {
                var token = _jwt.GenerateToken(admin);
                return Ok(new 
                { 
                    token, 
                    userName = admin.Name, 
                    email = admin.Email,
                    userId = admin.Id.ToString(),
                    role = admin.Role 
                });
            }

            return Unauthorized(new { error = "Invalid admin credentials" });
        }

        [HttpPost("change-password")]
        public IActionResult ChangePassword(ChangePasswordDto dto)
        {
            var oldPassHash = PasswordHasher.Hash(dto.OldPassword);
            var newPassHash = PasswordHasher.Hash(dto.NewPassword);

            // Check if user
            var user = _context.Users.FirstOrDefault(x => x.Email.ToLower() == dto.Email.ToLower());
            if (user != null)
            {
                if (user.Password != oldPassHash) return BadRequest(new { error = "Invalid old password" });
                user.Password = newPassHash;
                _context.SaveChanges();
                return Ok(new { message = "Password updated successfully" });
            }

            // Check if admin
            var admin = _context.Admins.FirstOrDefault(x => x.Email.ToLower() == dto.Email.ToLower());
            if (admin != null)
            {
                if (admin.Password != oldPassHash) return BadRequest(new { error = "Invalid old password" });
                admin.Password = newPassHash;
                _context.SaveChanges();
                return Ok(new { message = "Password updated successfully" });
            }

            return NotFound(new { error = "Account not found" });
        }

        [HttpPost("verify-email")]
        public IActionResult VerifyEmail(VerifyEmailDto dto)
        {
            var user = _context.Users.FirstOrDefault(x => x.Email.ToLower() == dto.Email.ToLower() && x.EmailConfirmationToken == dto.Token);
            if (user == null) return BadRequest(new { error = "Invalid token or email" });

            user.IsEmailConfirmed = true;
            user.EmailConfirmationToken = null;
            _context.SaveChanges();

            return Ok(new { message = "Email confirmed successfully" });
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordDto dto)
        {
            var user = _context.Users.FirstOrDefault(x => x.Email.ToLower() == dto.Email.ToLower());
            if (user == null) return NotFound(new { error = "User not found" });

            var token = new Random().Next(100000, 999999).ToString();
            user.ResetPasswordToken = token;
            user.ResetPasswordTokenExpiry = DateTime.UtcNow.AddMinutes(15);
            _context.SaveChanges();

            await _emailService.SendEmailAsync(user.Email, "Reset Password", $"Your password reset code is: <b>{token}</b>. It will expire in 15 minutes.");

            return Ok(new { message = "Reset code sent to your email." });
        }

        [HttpPost("reset-password")]
        public IActionResult ResetPassword(ResetPasswordDto dto)
        {
            var user = _context.Users.FirstOrDefault(x => x.Email.ToLower() == dto.Email.ToLower() && x.ResetPasswordToken == dto.Token);
            if (user == null) return BadRequest(new { error = "Invalid token or email" });

            if (user.ResetPasswordTokenExpiry < DateTime.UtcNow)
                return BadRequest(new { error = "Token expired" });

            user.Password = PasswordHasher.Hash(dto.NewPassword);
            user.ResetPasswordToken = null;
            user.ResetPasswordTokenExpiry = null;
            _context.SaveChanges();

            return Ok(new { message = "Password reset successfully" });
        }
    }
}