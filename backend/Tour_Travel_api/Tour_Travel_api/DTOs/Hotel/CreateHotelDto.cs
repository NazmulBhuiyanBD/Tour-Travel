namespace TravelApp.DTOs.Hotel
{
    public class CreateHotelDto
    {
        public string Name { get; set; }
        public string Location { get; set; }
        public string Description { get; set; }
        public string ImageUrl { get; set; }
        public decimal PricePerNight { get; set; }
        public bool IsFeatured { get; set; }
    }
}