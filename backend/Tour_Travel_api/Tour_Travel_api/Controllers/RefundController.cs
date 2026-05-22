using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using TravelApp.Models;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RefundController : ControllerBase
    {
        private readonly RefundService _refundService;

        public RefundController(RefundService refundService)
        {
            _refundService = refundService;
        }

        private int GetUserId()
        {
            return int.Parse(User.Claims.First(c => c.Type == ClaimTypes.NameIdentifier).Value);
        }

        private string GetUserName()
        {
            return User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Name)?.Value ?? "User";
        }

        [Authorize]
        [HttpPost]
        public async Task<IActionResult> CreateRefundRequest([FromBody] RefundRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            request.UserId = GetUserId();
            request.UserName = GetUserName();
            
            try
            {
                var createdRequest = await _refundService.CreateRefundRequestAsync(request);
                return Ok(createdRequest);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Authorize]
        [HttpGet("user")]
        public async Task<IActionResult> GetUserRefundRequests()
        {
            var userId = GetUserId();
            var requests = await _refundService.GetUserRefundRequestsAsync(userId);
            return Ok(requests);
        }

        [Authorize(Roles = "Admin,SuperAdmin")]
        [HttpGet("admin")]
        public async Task<IActionResult> GetAllRefundRequests()
        {
            var requests = await _refundService.GetAllRefundRequestsAsync();
            return Ok(requests);
        }

        [Authorize(Roles = "Admin,SuperAdmin")]
        [HttpPut("admin/{id}/status")]
        public async Task<IActionResult> UpdateRefundStatus(int id, [FromBody] StatusUpdateRequest update)
        {
            var success = await _refundService.UpdateRefundStatusAsync(id, update.Status);
            if (!success)
            {
                return NotFound(new { message = "Refund request not found." });
            }
            return Ok(new { message = "Refund status updated successfully." });
        }
    }

    public class StatusUpdateRequest
    {
        public string Status { get; set; } = string.Empty;
    }
}
