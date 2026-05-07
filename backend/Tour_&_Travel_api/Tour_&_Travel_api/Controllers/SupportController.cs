using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using TravelApp.Data;
using TravelApp.Models;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SupportController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SupportController(AppDbContext context)
        {
            _context = context;
        }

        public class CreateTicketDto
        {
            public string Subject { get; set; }
            public string InitialMessage { get; set; }
            public string? ImageUrl { get; set; }
        }

        public class SendMessageDto
        {
            public string Message { get; set; }
            public string? ImageUrl { get; set; }
        }

        private int GetCurrentUserId()
        {
            var claimsIdentity = User.Identity as ClaimsIdentity;
            var currentUserIdClaim = claimsIdentity?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(currentUserIdClaim, out int id) ? id : 0;
        }

        private string GetCurrentUserRole()
        {
            var claimsIdentity = User.Identity as ClaimsIdentity;
            return claimsIdentity?.FindFirst(ClaimTypes.Role)?.Value ?? "User";
        }

        [HttpPost("ticket")]
        [Authorize]
        public async Task<IActionResult> CreateTicket([FromBody] CreateTicketDto dto)
        {
            var userId = GetCurrentUserId();
            if (userId == 0) return Unauthorized();

            var ticket = new SupportTicket
            {
                UserId = userId,
                Subject = dto.Subject,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsClosed = false
            };

            _context.SupportTickets.Add(ticket);
            await _context.SaveChangesAsync();

            var message = new ChatMessage
            {
                TicketId = ticket.Id,
                SenderId = userId,
                Message = dto.InitialMessage,
                ImageUrl = dto.ImageUrl,
                IsAdminMessage = false,
                Timestamp = DateTime.UtcNow,
                IsRead = false
            };

            _context.ChatMessages.Add(message);
            await _context.SaveChangesAsync();

            return Ok(ticket);
        }

        [HttpGet("tickets/user/{userId}")]
        [Authorize]
        public async Task<IActionResult> GetUserTickets(int userId)
        {
            var currentUserId = GetCurrentUserId();
            var role = GetCurrentUserRole();

            if (role != "Admin" && role != "SuperAdmin" && currentUserId != userId)
                return Forbid();

            var tickets = await _context.SupportTickets
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.UpdatedAt)
                .ToListAsync();

            return Ok(tickets);
        }

        [HttpGet("tickets")]
        [Authorize(Roles = "Admin,SuperAdmin")]
        public async Task<IActionResult> GetAllTickets()
        {
            // We want to sort unread tickets first, then open tickets, then recently updated
            var tickets = await _context.SupportTickets
                .Include(t => t.User)
                .Include(t => t.Messages)
                .ToListAsync();

            var sortedTickets = tickets.Select(t => new
            {
                id = t.Id,
                subject = t.Subject,
                isClosed = t.IsClosed,
                createdAt = t.CreatedAt,
                updatedAt = t.UpdatedAt,
                userName = t.User?.Name,
                userEmail = t.User?.Email,
                hasUnread = t.Messages.Any(m => !m.IsRead && !m.IsAdminMessage)
            })
            .OrderByDescending(t => t.hasUnread)
            .ThenBy(t => t.isClosed)
            .ThenByDescending(t => t.updatedAt)
            .ToList();

            return Ok(sortedTickets);
        }

        [HttpGet("ticket/{ticketId}")]
        [Authorize]
        public async Task<IActionResult> GetTicket(int ticketId)
        {
            var ticket = await _context.SupportTickets
                .Include(t => t.Messages)
                .FirstOrDefaultAsync(t => t.Id == ticketId);

            if (ticket == null) return NotFound();

            var currentUserId = GetCurrentUserId();
            var role = GetCurrentUserRole();

            if (role != "Admin" && role != "SuperAdmin" && currentUserId != ticket.UserId)
                return Forbid();

            // Mark as read if admin is viewing user messages or user is viewing admin messages
            bool isAdmin = role == "Admin" || role == "SuperAdmin";
            bool messagesUpdated = false;
            
            foreach (var msg in ticket.Messages)
            {
                if (!msg.IsRead)
                {
                    if (isAdmin && !msg.IsAdminMessage)
                    {
                        msg.IsRead = true;
                        messagesUpdated = true;
                    }
                    else if (!isAdmin && msg.IsAdminMessage)
                    {
                        msg.IsRead = true;
                        messagesUpdated = true;
                    }
                }
            }

            if (messagesUpdated)
            {
                await _context.SaveChangesAsync();
            }

            // Also join admin info to messages for SuperAdmin visibility
            var messagesWithAdminNames = ticket.Messages.Select(m => {
                string adminName = null;
                if (m.IsAdminMessage && m.AdminId.HasValue)
                {
                    var admin = _context.Admins.Find(m.AdminId.Value);
                    adminName = admin?.Name;
                }
                return new {
                    id = m.Id,
                    ticketId = m.TicketId,
                    senderId = m.SenderId,
                    message = m.Message,
                    imageUrl = m.ImageUrl,
                    timestamp = m.Timestamp,
                    isAdminMessage = m.IsAdminMessage,
                    adminId = m.AdminId,
                    adminName = adminName,
                    isRead = m.IsRead
                };
            }).OrderBy(m => m.timestamp).ToList();

            return Ok(new {
                id = ticket.Id,
                subject = ticket.Subject,
                isClosed = ticket.IsClosed,
                createdAt = ticket.CreatedAt,
                updatedAt = ticket.UpdatedAt,
                messages = messagesWithAdminNames
            });
        }

        [HttpPost("ticket/{ticketId}/message")]
        [Authorize]
        public async Task<IActionResult> SendMessage(int ticketId, [FromBody] SendMessageDto dto)
        {
            var ticket = await _context.SupportTickets.FindAsync(ticketId);
            if (ticket == null) return NotFound();
            if (ticket.IsClosed) return BadRequest(new { error = "Ticket is closed" });

            var currentUserId = GetCurrentUserId();
            var role = GetCurrentUserRole();
            bool isAdmin = role == "Admin" || role == "SuperAdmin";

            if (!isAdmin && currentUserId != ticket.UserId)
                return Forbid();

            var message = new ChatMessage
            {
                TicketId = ticketId,
                SenderId = currentUserId,
                Message = dto.Message,
                ImageUrl = dto.ImageUrl,
                IsAdminMessage = isAdmin,
                AdminId = isAdmin ? currentUserId : null,
                Timestamp = DateTime.UtcNow,
                IsRead = false
            };

            ticket.UpdatedAt = DateTime.UtcNow;

            _context.ChatMessages.Add(message);
            await _context.SaveChangesAsync();

            string adminName = null;
            if (isAdmin)
            {
                var admin = await _context.Admins.FindAsync(currentUserId);
                adminName = admin?.Name;
            }

            return Ok(new {
                id = message.Id,
                ticketId = message.TicketId,
                senderId = message.SenderId,
                message = message.Message,
                imageUrl = message.ImageUrl,
                timestamp = message.Timestamp,
                isAdminMessage = message.IsAdminMessage,
                adminId = message.AdminId,
                adminName = adminName,
                isRead = message.IsRead
            });
        }
        
        [HttpPost("upload")]
        [Authorize]
        public async Task<IActionResult> Upload(IFormFile file, [FromServices] FileService fileService)
        {
            if (file == null || file.Length == 0) return BadRequest("File is empty");
            var path = await fileService.Upload(file);
            return Ok(new { path });
        }

        [HttpPut("ticket/{ticketId}/close")]
        [Authorize(Roles = "Admin,SuperAdmin")]
        public async Task<IActionResult> CloseTicket(int ticketId)
        {
            var ticket = await _context.SupportTickets.FindAsync(ticketId);
            if (ticket == null) return NotFound();

            ticket.IsClosed = true;
            ticket.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { status = "Closed" });
        }
    }
}
