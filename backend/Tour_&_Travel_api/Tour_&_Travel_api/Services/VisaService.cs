using TravelApp.Data;
using TravelApp.DTOs.Visa;
using TravelApp.Models;

namespace TravelApp.Services
{
    public class VisaService
    {
        private readonly AppDbContext _context;

        public VisaService(AppDbContext context)
        {
            _context = context;
        }

        public void AddVisa(CreateVisaDto dto)
        {
            _context.Visas.Add(new Visa
            {
                Country = dto.Country,
                VisaType = dto.VisaType,
                Description = dto.Description,
                Fee = dto.Fee
            });

            _context.SaveChanges();
        }
    }
}