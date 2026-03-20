namespace TravelApp.DTOs.Hotel
{
    public class CreateRoomDto
    {
        public int HotelId { get; set; }
        public string Type { get; set; }
        public decimal Price { get; set; }
        public int AvailableRooms { get; set; }
    }
}