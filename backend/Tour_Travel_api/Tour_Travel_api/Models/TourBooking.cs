namespace TravelApp.Models
{
    public class TourBooking
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int TourId { get; set; }
        public int ParticipantCount { get; set; } = 1;
        public decimal TotalPrice { get; set; }
        public string Status { get; set; } = "Confirmed";
        
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }

        public DateTime BookingDate { get; set; } = DateTime.UtcNow;
    }
}

