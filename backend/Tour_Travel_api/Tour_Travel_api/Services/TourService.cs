using TravelApp.Data;
using TravelApp.DTOs.Tour;
using TravelApp.Helpers;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class TourService
    {
        private readonly AppDbContext _context;
        private readonly NotificationService _notificationService;

        public TourService(AppDbContext context, NotificationService notificationService)
        {
            _context = context;
            _notificationService = notificationService;
        }

        public void AddTour(CreateTourDto dto)
        {
            _context.Tours.Add(new Tour
            {
                Title = dto.Title,
                Description = dto.Description,
                DurationDays = dto.DurationDays,
                Price = dto.Price,
                StartPoint = dto.StartPoint ?? "Dhaka",
                EndPoint = dto.EndPoint ?? "",
                Itinerary = dto.Itinerary,
                IsTopDestination = dto.IsTopDestination,
                ImageUrl = dto.ImageUrl ?? "",
                StartDate = dto.StartDate,
                Vacancy = dto.Vacancy
            });
            _context.SaveChanges();
        }

        public List<Tour> GetTours() => _context.Tours.ToList();

        public List<Tour> GetTopDestinations() =>
            _context.Tours.Where(t => t.IsTopDestination).ToList();

        public async Task BookTour(int userId, BookTourDto dto)
        {
            BookingValidation.ValidateQuantity(dto.ParticipantCount, "participants");

            var tour = _context.Tours.Find(dto.TourId)
                ?? throw new Exception("Tour not found");

            if (tour.StartDate <= DateTime.UtcNow)
                throw new Exception("This tour has already started and cannot be booked.");

            if (tour.Vacancy < dto.ParticipantCount)
                throw new Exception($"Only {tour.Vacancy} spot(s) remaining.");

            tour.Vacancy -= dto.ParticipantCount;
            var totalPrice = tour.Price * dto.ParticipantCount;

            _context.TourBookings.Add(new TourBooking
            {
                UserId = userId,
                TourId = dto.TourId,
                ParticipantCount = dto.ParticipantCount,
                TotalPrice = totalPrice,
                Status = "Confirmed",
                BookingDate = DateTime.UtcNow,
                PaymentMethod = dto.PaymentMethod,
                TransactionId = dto.TransactionId
            });

            await _context.SaveChangesAsync();

            try
            {
                await _notificationService.CreateNotificationAsync(userId, "Tour Booked Successfully",
                    $"Your tour '{tour.Title}' is confirmed for {dto.ParticipantCount} participant(s). Start date: {tour.StartDate:yyyy-MM-dd}. Total: ${totalPrice}.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Notification error: {ex.Message}");
            }
        }
    }
}
