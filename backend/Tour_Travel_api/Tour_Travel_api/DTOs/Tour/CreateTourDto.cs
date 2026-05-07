namespace TravelApp.DTOs.Tour
{
    public class CreateTourDto
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public int DurationDays { get; set; }
        public decimal Price { get; set; }
        public string Itinerary { get; set; }
        public bool IsTopDestination { get; set; }
        public string? ImageUrl { get; set; }
    }
}
