using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TravelApp.Models
{
    public class SupportTicket
    {
        public int Id { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        public string Subject { get; set; }
        
        public bool IsClosed { get; set; } = false;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [JsonIgnore]
        public User User { get; set; }
        
        [JsonIgnore]
        public ICollection<ChatMessage> Messages { get; set; }
    }
}
