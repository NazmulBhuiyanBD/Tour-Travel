using System.ComponentModel.DataAnnotations;

namespace TravelApp.DTOs.Flight
{
    public class CreateFlightDto
    {
        public string Airline { get; set; }
        public string From { get; set; }
        public string To { get; set; }

        public DateTime DepartureTime { get; set; }
        public DateTime ArrivalTime { get; set; }

        [Range(typeof(decimal), "0.01", "79228162514264337593543950335", ErrorMessage = "Flight price must be greater than zero.")]
        public decimal Price { get; set; }
        [Range(1, int.MaxValue, ErrorMessage = "Available seats must be greater than zero.")]
        public int AvailableSeats { get; set; }
        public bool IsPopular { get; set; }
        public List<FlightSeatClassDto>? SeatClasses { get; set; }
    }
}
