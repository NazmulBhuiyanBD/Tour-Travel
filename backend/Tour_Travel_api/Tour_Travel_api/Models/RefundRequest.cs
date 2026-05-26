using System;

namespace TravelApp.Models
{
    public class RefundRequest
    {
        public int Id { get; set; }
        
        public int UserId { get; set; }
        public string? UserName { get; set; }
        
        public string? ItemType { get; set; } // "Flight", "Hotel", "Tour"
        public int BookingId { get; set; }
        
        public string? Reason { get; set; }
        
        public string Status { get; set; } = "Pending"; // "Pending", "Approved", "Rejected"
        
        public int RefundPercentage { get; set; } = 100;
        public decimal RefundAmount { get; set; } = 0;
        public decimal BookingPrice { get; set; } = 0;
        public string? AdminFeedback { get; set; }
        
        public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
    }
}
