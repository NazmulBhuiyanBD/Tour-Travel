using System.ComponentModel.DataAnnotations;

namespace TravelApp.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required]
        public string Name { get; set; }

        [Required, EmailAddress]
        public string Email { get; set; }

        [Required]
        public string Password { get; set; }

        public string Phone { get; set; }

        public string Role { get; set; } = "User";

        public bool IsActive { get; set; } = true;

        public bool IsEmailConfirmed { get; set; } = false;

        public string? EmailConfirmationToken { get; set; }

        public string? ResetPasswordToken { get; set; }

        public DateTime? ResetPasswordTokenExpiry { get; set; }
    }
}