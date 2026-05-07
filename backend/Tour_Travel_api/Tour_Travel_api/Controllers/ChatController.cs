using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using TravelApp.Data;
using TravelApp.Models;

namespace TravelApp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ChatController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/chat/history/{userId}
        [HttpGet("history/{userId}")]
        [Authorize]
        public async Task<IActionResult> GetChatHistory(int userId)
        {
            var claimsIdentity = User.Identity as ClaimsIdentity;
            var currentUserIdClaim = claimsIdentity?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var roleClaim = claimsIdentity?.FindFirst(ClaimTypes.Role)?.Value;

            if (currentUserIdClaim == null) return Unauthorized();
            
            bool isAdmin = roleClaim == "Admin";
            int currentUid = int.Parse(currentUserIdClaim);

            // If user is not admin and asking for someone else's chat history
            if (!isAdmin && currentUid != userId)
            {
                return Forbid();
            }

            var history = await _context.ChatMessages
                .Where(m => (m.SenderId == userId && m.IsAdminMessage == false) || (m.ReceiverId == userId && m.IsAdminMessage == true))
                .OrderBy(m => m.Timestamp)
                .ToListAsync();

            return Ok(history);
        }

        // GET: api/chat/users
        [HttpGet("users")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetUserChatList()
        {
            var messages = await _context.ChatMessages.ToListAsync();
            
            var latestMessages = messages
                .GroupBy(m => m.IsAdminMessage ? m.ReceiverId : m.SenderId)
                .Select(g => new
                {
                    UserId = g.Key,
                    LatestMessage = g.OrderByDescending(m => m.Timestamp).FirstOrDefault()
                })
                .ToList();

            var result = new List<object>();

            foreach (var item in latestMessages)
            {
                var user = await _context.Users.FindAsync(item.UserId);
                if (user != null)
                {
                    result.Add(new
                    {
                        UserId = user.Id,
                        UserName = user.Name,
                        UserEmail = user.Email,
                        LatestMessage = item.LatestMessage?.Message ?? "",
                        Timestamp = item.LatestMessage?.Timestamp,
                        IsSystemMessage = item.LatestMessage?.IsAdminMessage ?? false
                    });
                }
            }

            return Ok(result.OrderByDescending(r => (DateTime?)r.GetType().GetProperty("Timestamp")?.GetValue(r, null)));
        }
    }
}
