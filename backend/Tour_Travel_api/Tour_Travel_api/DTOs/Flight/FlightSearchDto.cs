namespace TravelApp.DTOs.Flight
{
    public class FlightSearchDto
    {
        public string From { get; set; }
        public string To { get; set; }
        public DateTime Date { get; set; }

        public decimal? MaxPrice { get; set; }
    }
}