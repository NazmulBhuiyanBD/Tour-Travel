using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentController : ControllerBase
    {
        private readonly PaymentService _paymentService;

        public PaymentController(PaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        public class PaymentRequestDto
        {
            public decimal Amount { get; set; }
        }

        [HttpPost("init")]
        public async Task<IActionResult> InitPayment([FromBody] PaymentRequestDto dto)
        {
            try
            {
                var result = await _paymentService.Pay(dto.Amount);
                return Ok(new { gatewayUrl = "https://sandbox.sslcommerz.com/mock_checkout_page", rawPayload = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
