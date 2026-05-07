using TravelApp.Data;
using TravelApp.DTOs.Tour;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class TourService
    {
        private readonly AppDbContext _context;

        public TourService(AppDbContext context)
        {
            _context = context;
        }

        public void AddTour(CreateTourDto dto)
        {
            _context.Tours.Add(new Tour
            {
                Title = dto.Title,
                Description = dto.Description,
                DurationDays = dto.DurationDays,
                Price = dto.Price,
                Itinerary = dto.Itinerary
            });

            _context.SaveChanges();
        }

        public List<Tour> GetTours()
        {
            return _context.Tours.ToList();
        }

        public List<Tour> GetTopDestinations()
        {
            return _context.Tours.Where(t => t.IsTopDestination).ToList();
        }

        public void BookTour(int userId, BookTourDto dto)
        {
            var tour = _context.Tours.Find(dto.TourId);

            if (tour == null)
                throw new Exception("Tour not found");

            _context.TourBookings.Add(new TourBooking
            {
                UserId = userId,
                TourId = dto.TourId,
                Status = "Confirmed",
                BookingDate = DateTime.UtcNow,
                PaymentMethod = dto.PaymentMethod,
                TransactionId = dto.TransactionId
            });

            _context.SaveChanges();
        }
    }
}
