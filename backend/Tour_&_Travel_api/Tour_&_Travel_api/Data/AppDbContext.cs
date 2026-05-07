using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using TravelApp.Models;

namespace TravelApp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options) { }

        public DbSet<Admin> Admins { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Flight> Flights { get; set; }
        public DbSet<FlightBooking> FlightBookings { get; set; }

        public DbSet<Hotel> Hotels { get; set; }
        public DbSet<Room> Rooms { get; set; }
        public DbSet<HotelBooking> HotelBookings { get; set; }
        public DbSet<HotelReview> HotelReviews { get; set; }


        public DbSet<Tour> Tours { get; set; }
        public DbSet<TourBooking> TourBookings { get; set; }
        
        public DbSet<ChatMessage> ChatMessages { get; set; }
        public DbSet<SupportTicket> SupportTickets { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // Configure relationship between SupportTicket and ChatMessage
            modelBuilder.Entity<ChatMessage>()
                .HasOne(m => m.Ticket)
                .WithMany(t => t.Messages)
                .HasForeignKey(m => m.TicketId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}