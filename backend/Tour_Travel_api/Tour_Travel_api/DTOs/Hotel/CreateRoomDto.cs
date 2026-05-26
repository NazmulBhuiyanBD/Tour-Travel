using System.ComponentModel.DataAnnotations;

namespace TravelApp.DTOs.Hotel
{
    public class CreateRoomDto
    {
        public int HotelId { get; set; }
        public string Type { get; set; }
        public string BedType { get; set; } = "King Bed";
        public string ViewType { get; set; } = "City View";
        public bool IsAc { get; set; } = true;
        [Range(typeof(decimal), "0.01", "79228162514264337593543950335", ErrorMessage = "Room price must be greater than zero.")]
        public decimal Price { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Available rooms must be greater than zero.")]
        public int AvailableRooms { get; set; }
    }
}
