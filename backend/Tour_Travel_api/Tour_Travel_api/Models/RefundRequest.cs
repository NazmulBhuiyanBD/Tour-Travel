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
        
        public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
    }
}
