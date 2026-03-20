using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TravelApp.Data;
using TravelApp.DTOs.Visa;
using TravelApp.Models;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VisaController : ControllerBase
    {
        private readonly AppDbContext _context;

        public VisaController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier));

        [Authorize(Roles = "Admin")]
        [HttpPost("add")]
        public IActionResult Add(CreateVisaDto dto)
        {
            _context.Visas.Add(new Visa
            {
                Country = dto.Country,
                VisaType = dto.VisaType,
                Description = dto.Description,
                Fee = dto.Fee
            });

            _context.SaveChanges();
            return Ok();
        }

        [HttpGet]
        public IActionResult Get() => Ok(_context.Visas.ToList());

        [Authorize]
        [HttpPost("apply")]
        public IActionResult Apply(ApplyVisaDto dto)
        {
            _context.VisaApplications.Add(new VisaApplication
            {
                UserId = GetUserId(),
                VisaId = dto.VisaId
            });

            _context.SaveChanges();
            return Ok();
        }
    }
}