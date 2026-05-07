namespace TravelApp.Models
{
    public class Hotel
    {
        public int Id { get; set; }

        public string Name { get; set; }
        public string Location { get; set; }
        public string Description { get; set; }

        public double Rating { get; set; } = 0;
        public string ImageUrl { get; set; } = "";
        public string? GalleryImages { get; set; } // Comma-separated image URLs
        public decimal PricePerNight { get; set; }
        public bool IsFeatured { get; set; } = false;
    }
}