using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using TravelApp.Models;

namespace TravelApp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Flight> Flights { get; set; }
        public DbSet<FlightBooking> FlightBookings { get; set; }

        public DbSet<Hotel> Hotels { get; set; }
        public DbSet<Room> Rooms { get; set; }
        public DbSet<HotelBooking> HotelBookings { get; set; }
        public DbSet<HotelReview> HotelReviews { get; set; }

        public DbSet<Visa> Visas { get; set; }
        public DbSet<VisaApplication> VisaApplications { get; set; }
        public DbSet<VisaDocument> VisaDocuments { get; set; }
    }
}