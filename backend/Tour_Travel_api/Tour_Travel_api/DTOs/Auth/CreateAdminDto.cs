using System.ComponentModel.DataAnnotations;

namespace TravelApp.DTOs.Auth
{
    public class CreateAdminDto
    {
        [Required]
        public string Name { get; set; }

        [Required, EmailAddress]
        public string Email { get; set; }

        [Required]
        public string Password { get; set; }

        public string Phone { get; set; }

        public string Role { get; set; } = "Admin";
    }
}
