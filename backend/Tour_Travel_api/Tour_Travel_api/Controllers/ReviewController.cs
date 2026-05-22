using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewController : ControllerBase
    {
        private readonly ReviewService _reviewService;

        public ReviewController(ReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        private string GetUserName() =>
            User.FindFirstValue(ClaimTypes.Name) ?? "User";

        [Authorize]
        [HttpPost]
        public IActionResult AddReview([FromBody] CreateReviewDto dto)
        {
            try
            {
                var userId = GetUserId();
                var userName = GetUserName();
                _reviewService.AddReview(userId, userName, dto.ItemType, dto.ItemId, dto.Rating, dto.Comment);
                return Ok(new { message = "Review added successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Authorize]
        [HttpGet("user")]
        public IActionResult GetUserReviews()
        {
            var userId = GetUserId();
            var reviews = _reviewService.GetUserReviews(userId);
            return Ok(new { reviews });
        }

        [Authorize]
        [HttpGet("can-review/{itemType}/{itemId}")]
        public IActionResult CanReview(string itemType, int itemId)
        {
            var userId = GetUserId();
            return Ok(new { canReview = _reviewService.CanUserReview(userId, itemType, itemId) });
        }

        [HttpGet("{itemType}/{itemId}")]
        public IActionResult GetReviews(string itemType, int itemId)
        {
            var reviews = _reviewService.GetReviews(itemType, itemId);
            var avgRating = _reviewService.GetAverageRating(itemType, itemId);
            var count = _reviewService.GetReviewCount(itemType, itemId);

            return Ok(new
            {
                reviews,
                averageRating = avgRating,
                totalReviews = count
            });
        }
    }

    public class CreateReviewDto
    {
        public string ItemType { get; set; } = string.Empty;
        public int ItemId { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
    }
}
