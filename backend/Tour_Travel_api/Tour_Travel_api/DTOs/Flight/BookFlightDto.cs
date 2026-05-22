namespace TravelApp.DTOs.Flight
{
    public class BookFlightDto
    {
        public int FlightId { get; set; }
        public string SeatClass { get; set; } = "Economy";
        public int SeatCount { get; set; }
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }
    }
}