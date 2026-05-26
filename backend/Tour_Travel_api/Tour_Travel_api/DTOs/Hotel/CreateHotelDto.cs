using System.ComponentModel.DataAnnotations;

namespace TravelApp.DTOs.Hotel
{
    public class CreateHotelDto
    {
        public string Name { get; set; }
        public string Location { get; set; }
        public string Description { get; set; }
        public string ImageUrl { get; set; }
        public string? Amenities { get; set; }
        [Range(typeof(decimal), "0.01", "79228162514264337593543950335", ErrorMessage = "Price per night must be greater than zero.")]
        public decimal PricePerNight { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Available rooms must be greater than zero.")]
        public int AvailableRooms { get; set; } = 10;
        public bool IsFeatured { get; set; }
        public string? ContactInfo { get; set; }
        public string RoomType { get; set; } = "Single Room";
        public string BedType { get; set; } = "King Bed";
        public string ViewType { get; set; } = "City View";
        public bool IsAc { get; set; } = true;
    }
}
