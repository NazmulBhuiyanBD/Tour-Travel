using System.Text.Json.Serialization;

namespace TravelApp.Models
{
    public class FlightSeatClass
    {
        public int Id { get; set; }
        public int FlightId { get; set; }
        public string ClassName { get; set; } = "Economy";
        public int AvailableSeats { get; set; }
        public decimal Price { get; set; }

        [JsonIgnore]
        public Flight Flight { get; set; } = null!;
    }
}
