namespace TravelApp.Models
{
    public class Visa
    {
        public int Id { get; set; }

        public string Country { get; set; }
        public string VisaType { get; set; }

        public string Description { get; set; }
        public decimal Fee { get; set; }
    }
}