using System.ComponentModel.DataAnnotations;

namespace TravelApp.Models
{
    public class Review
    {
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        public string UserName { get; set; } = string.Empty;

        [Required]
        public string ItemType { get; set; } = string.Empty; // "Tour" or "Hotel"

        [Required]
        public int ItemId { get; set; }

        [Range(1, 5)]
        public int Rating { get; set; }

        public string Comment { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
