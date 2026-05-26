using System.ComponentModel.DataAnnotations;

namespace TravelApp.DTOs.Tour
{
    public class CreateTourDto
    {
        public string Title { get; set; }
        public string Description { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Duration must be greater than zero.")]
        public int DurationDays { get; set; }
        [Range(typeof(decimal), "0.01", "79228162514264337593543950335", ErrorMessage = "Tour price must be greater than zero.")]
        public decimal Price { get; set; }
        public string? StartPoint { get; set; }
        public string? EndPoint { get; set; }
        public string Itinerary { get; set; }
        public bool IsTopDestination { get; set; }
        public string? ImageUrl { get; set; }
        public DateTime StartDate { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Vacancy must be greater than zero.")]
        public int Vacancy { get; set; } = 20;
    }
}
