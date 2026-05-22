namespace TravelApp.Models
{
    public class Tour
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int DurationDays { get; set; }
        public decimal Price { get; set; }
        public string StartPoint { get; set; } = "Dhaka";
        public string EndPoint { get; set; } = string.Empty;
        public string Itinerary { get; set; } = string.Empty;
        public bool IsTopDestination { get; set; } = false;
        public string ImageUrl { get; set; } = string.Empty;
        public string? GalleryImages { get; set; } // Comma-separated image URLs
        public DateTime StartDate { get; set; } = DateTime.UtcNow.AddDays(7);
        public int Vacancy { get; set; } = 0;
    }
}
