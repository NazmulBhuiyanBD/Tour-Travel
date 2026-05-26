namespace TravelApp.Models
{
    public class HotelBooking
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public int RoomId { get; set; }

        public DateTime CheckIn { get; set; }
        public DateTime CheckOut { get; set; }
        public int RoomCount { get; set; } = 1;

        public decimal TotalPrice { get; set; }

        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }
        public string Status { get; set; } = "Confirmed";
        public DateTime BookingDate { get; set; } = DateTime.UtcNow;

        public Room Room { get; set; }
    }
}