namespace TravelApp.DTOs.Hotel
{
    public class CreateHotelDto
    {
        public string Name { get; set; }
        public string Location { get; set; }
        public string Description { get; set; }
        public string ImageUrl { get; set; }
        public string? Amenities { get; set; }
        public decimal PricePerNight { get; set; }
        public int AvailableRooms { get; set; } = 10;
        public bool IsFeatured { get; set; }
    }
}