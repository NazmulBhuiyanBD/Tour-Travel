namespace TravelApp.Models
{
    public class FlightBooking
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public int FlightId { get; set; }

        public int SeatCount { get; set; }
        public decimal TotalPrice { get; set; }
        
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }

        public DateTime BookingDate { get; set; } = DateTime.Now;

        public Flight Flight { get; set; }
    }
}