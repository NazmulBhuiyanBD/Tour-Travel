using System;

namespace TravelApp.Models
{
    public class ChatMessage
    {
        public int Id { get; set; }
        
        // Nullable TicketId to avoid crash on existing data, but we'll use it going forward
        public int? TicketId { get; set; }
        
        public int SenderId { get; set; } // User ID or Admin ID
        
        // ReceiverId is mostly legacy now since we use TicketId, but keep it
        public int ReceiverId { get; set; } 
        
        public string Message { get; set; } = string.Empty;
        public string? ImageUrl { get; set; } // Optional image attached
        
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
        
        public bool IsAdminMessage { get; set; } // True if sent by admin
        public int? AdminId { get; set; } // The actual admin who replied
        
        public bool IsRead { get; set; } = false;
        
        [System.Text.Json.Serialization.JsonIgnore]
        public SupportTicket? Ticket { get; set; }
    }
}
