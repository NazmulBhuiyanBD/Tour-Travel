namespace TravelApp.DTOs.Hotel
{
    public class BookHotelDto
    {
        public int HotelId { get; set; }
        public int RoomId { get; set; }
        public DateTime CheckIn { get; set; }
        public DateTime CheckOut { get; set; }
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }
    }
}