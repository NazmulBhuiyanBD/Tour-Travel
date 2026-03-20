using TravelApp.Data;
using TravelApp.DTOs.User;

namespace TravelApp.Services
{
    public class UserService
    {
        private readonly AppDbContext _context;

        public UserService(AppDbContext context)
        {
            _context = context;
        }

        public object GetProfile(int userId)
        {
            var user = _context.Users.Find(userId);
            return user;
        }

        public string UpdateProfile(int userId, UpdateProfileDto dto)
        {
            var user = _context.Users.Find(userId);

            user.Name = dto.Name;
            user.Phone = dto.Phone;

            _context.SaveChanges();
            return "Profile updated";
        }

        public string ChangePassword(int userId, ChangePasswordDto dto)
        {
            var user = _context.Users.Find(userId);

            if (user.Password != PasswordHasher.Hash(dto.OldPassword))
                throw new Exception("Old password incorrect");

            user.Password = PasswordHasher.Hash(dto.NewPassword);

            _context.SaveChanges();
            return "Password changed";
        }
    }
}