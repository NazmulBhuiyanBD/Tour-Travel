namespace TravelApp.DTOs.Booking
{
    public class BookingHistoryDto
    {
        public string Type { get; set; } = string.Empty;
        public int ReferenceId { get; set; }
        public int ItemId { get; set; }
        public string ReferenceNumber { get; set; } = string.Empty;
        public string DetailTitle { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public decimal TotalPrice { get; set; }
        public DateTime BookingDate { get; set; }

        // Enriched Fields for UI
        public string Airline { get; set; } = string.Empty;
        public string From { get; set; } = string.Empty;
        public string To { get; set; } = string.Empty;
        public DateTime? ArrivalTime { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string PaymentMethod { get; set; } = string.Empty;
        public string TransactionId { get; set; } = string.Empty;

        public int Quantity { get; set; } = 1;
        public string SeatClass { get; set; } = string.Empty;
        public DateTime? CheckOutDate { get; set; }
        public DateTime? ServiceEndDate { get; set; }
        public bool CanReview { get; set; }
        public bool CanRefund { get; set; }
    }
}
