namespace TravelApp.DTOs.Visa
{
    public class CreateVisaDto
    {
        public string Country { get; set; }
        public string VisaType { get; set; }
        public string Description { get; set; }
        public decimal Fee { get; set; }
    }
}