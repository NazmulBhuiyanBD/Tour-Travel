namespace TravelApp.DTOs.Booking
{
    public class BookingHistoryDto
    {
        public string Type { get; set; } = string.Empty;
        public int ReferenceId { get; set; }
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
    }
}
