namespace TravelApp.Models
{
    public class VisaApplication
    {
        public int Id { get; set; }

        public int UserId { get; set; }
        public int VisaId { get; set; }

        public string Status { get; set; } = "Pending";

        public DateTime AppliedDate { get; set; } = DateTime.Now;

        public Visa Visa { get; set; }
    }
}