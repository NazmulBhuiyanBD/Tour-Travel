namespace TravelApp.Models
{
    public class Room
    {
        public int Id { get; set; }

        public int HotelId { get; set; }

        public string Type { get; set; } // Single Room, Double Room, Family Room
        public string BedType { get; set; } = "King Bed";
        public string ViewType { get; set; } = "City View";
        public bool IsAc { get; set; } = true;
        public decimal Price { get; set; }

        public int AvailableRooms { get; set; }

        public Hotel Hotel { get; set; }
    }
}
