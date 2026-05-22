namespace TravelApp.DTOs.User
{
    public class UpdateProfileDto
    {
        public string Name { get; set; }
        public string Phone { get; set; }
        public string? Gender { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? Address { get; set; }
        public string? ProfilePicture { get; set; }
    }
}