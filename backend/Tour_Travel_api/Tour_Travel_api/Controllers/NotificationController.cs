using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationController : ControllerBase
    {
        private readonly NotificationService _notificationService;

        public NotificationController(NotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        private int GetUserId()
        {
            return int.Parse(User.Claims.First(c => c.Type == ClaimTypes.NameIdentifier).Value);
        }

        [HttpGet]
        public async Task<IActionResult> GetNotifications()
        {
            var userId = GetUserId();
            var notifications = await _notificationService.GetUserNotificationsAsync(userId);
            return Ok(notifications);
        }

        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var userId = GetUserId();
            var success = await _notificationService.MarkAsReadAsync(id, userId);
            if (!success)
            {
                return NotFound(new { message = "Notification not found or unauthorized." });
            }
            return Ok(new { message = "Notification marked as read." });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteNotification(int id)
        {
            var userId = GetUserId();
            var success = await _notificationService.DeleteNotificationAsync(id, userId);
            if (!success)
            {
                return NotFound(new { message = "Notification not found or unauthorized." });
            }
            return Ok(new { message = "Notification deleted successfully." });
        }
    }
}
