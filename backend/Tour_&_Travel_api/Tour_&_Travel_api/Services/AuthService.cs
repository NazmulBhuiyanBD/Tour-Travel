using TravelApp.Data;
using TravelApp.DTOs.Auth;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class AuthService
    {
        private readonly AppDbContext _context;
        private readonly JwtService _jwt;

        public AuthService(AppDbContext context, JwtService jwt)
        {
            _context = context;
            _jwt = jwt;
        }

        public string Register(RegisterDto dto)
        {
            if (_context.Users.Any(x => x.Email == dto.Email))
                throw new Exception("Email already exists");

            var user = new User
            {
                Name = dto.Name,
                Email = dto.Email,
                Password = PasswordHasher.Hash(dto.Password),
                Phone = dto.Phone
            };

            _context.Users.Add(user);
            _context.SaveChanges();

            return "User Registered";
        }

        public object Login(LoginDto dto)
        {
            var pass = PasswordHasher.Hash(dto.Password);

            var user = _context.Users
                .FirstOrDefault(x => x.Email == dto.Email && x.Password == pass);

            if (user == null)
                throw new Exception("Invalid credentials");

            var token = _jwt.GenerateToken(user);

            return new { token, user.Name, user.Role };
        }
    }
}