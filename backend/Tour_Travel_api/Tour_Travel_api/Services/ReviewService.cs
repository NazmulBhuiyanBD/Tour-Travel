using Microsoft.EntityFrameworkCore;
using TravelApp.Data;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class ReviewService
    {
        private readonly AppDbContext _context;

        public ReviewService(AppDbContext context)
        {
            _context = context;
        }

        public void AddReview(int userId, string userName, string itemType, int itemId, int rating, string comment)
        {
            if (rating < 1 || rating > 5)
                throw new Exception("Rating must be between 1 and 5.");

            if (!CanUserReview(userId, itemType, itemId))
                throw new Exception($"You can only review this {itemType} after your stay or trip has started.");

            var existingReview = _context.Reviews
                .FirstOrDefault(r => r.UserId == userId && r.ItemType == itemType && r.ItemId == itemId);

            if (existingReview != null)
                throw new Exception("You have already reviewed this item.");

            _context.Reviews.Add(new Review
            {
                UserId = userId,
                UserName = userName,
                ItemType = itemType,
                ItemId = itemId,
                Rating = rating,
                Comment = comment,
                CreatedAt = DateTime.UtcNow
            });

            _context.SaveChanges();

            if (itemType == "Hotel")
            {
                var hotel = _context.Hotels.Find(itemId);
                if (hotel != null)
                {
                    hotel.Rating = Math.Round(_context.Reviews
                        .Where(r => r.ItemType == "Hotel" && r.ItemId == itemId)
                        .Average(r => r.Rating), 1);
                    _context.SaveChanges();
                }
            }
        }

        public bool CanUserReview(int userId, string itemType, int itemId)
        {
            var now = DateTime.UtcNow;

            if (itemType == "Hotel")
            {
                return _context.HotelBookings
                    .Join(_context.Rooms, hb => hb.RoomId, r => r.Id, (hb, r) => new { hb, r })
                    .Any(x => x.hb.UserId == userId
                        && x.hb.Status == "Confirmed"
                        && x.r.HotelId == itemId
                        && x.hb.CheckIn <= now);
            }

            if (itemType == "Flight")
            {
                return _context.FlightBookings
                    .Join(_context.Flights, fb => fb.FlightId, f => f.Id, (fb, f) => new { fb, f })
                    .Any(x => x.fb.UserId == userId
                        && x.fb.Status == "Confirmed"
                        && x.f.Id == itemId
                        && x.f.ArrivalTime <= now);
            }

            if (itemType == "Tour")
            {
                return _context.TourBookings
                    .Join(_context.Tours, tb => tb.TourId, t => t.Id, (tb, t) => new { tb, t })
                    .Any(x => x.tb.UserId == userId
                        && x.tb.Status == "Confirmed"
                        && x.t.Id == itemId
                        && x.t.StartDate.AddDays(x.t.DurationDays) <= now);
            }

            return false;
        }

        public List<Review> GetReviews(string itemType, int itemId) =>
            _context.Reviews
                .Where(r => r.ItemType == itemType && r.ItemId == itemId)
                .OrderByDescending(r => r.CreatedAt)
                .ToList();

        public List<Review> GetUserReviews(int userId) =>
            _context.Reviews
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.CreatedAt)
                .ToList();

        public double GetAverageRating(string itemType, int itemId)
        {
            var reviews = _context.Reviews.Where(r => r.ItemType == itemType && r.ItemId == itemId);
            return reviews.Any() ? Math.Round(reviews.Average(r => r.Rating), 1) : 0;
        }

        public int GetReviewCount(string itemType, int itemId) =>
            _context.Reviews.Count(r => r.ItemType == itemType && r.ItemId == itemId);
    }
}
