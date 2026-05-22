namespace TravelApp.DTOs.Tour
{
    public class BookTourDto
    {
        public int TourId { get; set; }
        public int ParticipantCount { get; set; } = 1;
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }
    }
}

