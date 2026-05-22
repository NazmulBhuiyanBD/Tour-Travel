namespace TravelApp.DTOs.Flight
{
    public class FlightSeatClassDto
    {
        public string ClassName { get; set; } = "Economy";
        public int AvailableSeats { get; set; }
        public decimal Price { get; set; }
    }
}
