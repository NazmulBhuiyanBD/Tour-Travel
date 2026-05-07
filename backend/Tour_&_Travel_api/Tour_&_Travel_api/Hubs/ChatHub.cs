using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
using System.Threading.Tasks;
using TravelApp.Data;
using TravelApp.Models;

namespace TravelApp.Hubs
{
    [Authorize]
    public class ChatHub : Hub
    {
        private readonly AppDbContext _context;

        public ChatHub(AppDbContext context)
        {
            _context = context;
        }

        public async Task SendMessageToAdmin(string message)
        {
            int userId = int.Parse(Context.User.FindFirstValue(ClaimTypes.NameIdentifier));
            
            var chatMsg = new ChatMessage
            {
                SenderId = userId,
                Message = message,
                Timestamp = DateTime.UtcNow,
                IsAdminMessage = false
            };
            
            _context.ChatMessages.Add(chatMsg);
            await _context.SaveChangesAsync();

            // Send to admins. We could use a group "Admins".
            await Clients.Group("Admins").SendAsync("ReceiveMessage", chatMsg);
        }

        public async Task SendMessageToUser(int userId, string message)
        {
            int adminId = int.Parse(Context.User.FindFirstValue(ClaimTypes.NameIdentifier));
            
            var chatMsg = new ChatMessage
            {
                SenderId = adminId,
                ReceiverId = userId,
                Message = message,
                Timestamp = DateTime.UtcNow,
                IsAdminMessage = true
            };
            
            _context.ChatMessages.Add(chatMsg);
            await _context.SaveChangesAsync();

            // Send to user
            await Clients.User(userId.ToString()).SendAsync("ReceiveMessage", chatMsg);
        }

        public override async Task OnConnectedAsync()
        {
            if (Context.User.IsInRole("Admin"))
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, "Admins");
            }
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            if (Context.User.IsInRole("Admin"))
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, "Admins");
            }
            await base.OnDisconnectedAsync(exception);
        }
    }
}
