using System.ComponentModel.DataAnnotations;

namespace TravelApp.DTOs.Flight
{
    public class FlightSeatClassDto
    {
        public string ClassName { get; set; } = "Economy";
        [Range(1, int.MaxValue, ErrorMessage = "Available seats must be greater than zero.")]
        public int AvailableSeats { get; set; }
        [Range(typeof(decimal), "0.01", "79228162514264337593543950335", ErrorMessage = "Seat class price must be greater than zero.")]
        public decimal Price { get; set; }
    }
}
