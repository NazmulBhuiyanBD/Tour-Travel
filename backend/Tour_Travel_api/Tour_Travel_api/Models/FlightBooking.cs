namespace TravelApp.Models
{
    public class FlightBooking
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public int FlightId { get; set; }

        public int SeatCount { get; set; }
        public string SeatClass { get; set; } = "Economy";
        public decimal TotalPrice { get; set; }
        
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }
        public string Status { get; set; } = "Confirmed";

        public DateTime BookingDate { get; set; } = DateTime.Now;

        public Flight Flight { get; set; }
    }
}