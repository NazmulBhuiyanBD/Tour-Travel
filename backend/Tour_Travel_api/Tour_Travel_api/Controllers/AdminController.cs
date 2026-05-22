using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TravelApp.Data;
using TravelApp.Models;
using TravelApp.DTOs.Tour;
using TravelApp.DTOs.Hotel;
using TravelApp.DTOs.Flight;

using TravelApp.Services;

namespace TravelApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,SuperAdmin")]
    public class AdminController : ControllerBase

    {
        private readonly AppDbContext _context;
        private readonly FileService _fileService;

        public AdminController(AppDbContext context, FileService fileService)
        {
            _context = context;
            _fileService = fileService;
        }

        #region User Management
        [HttpGet("users")]
        public IActionResult Users() =>
            Ok(_context.Users.ToList());

        [HttpPut("user/{id}/toggle-status")]
        public IActionResult ToggleUserStatus(int id)
        {
            var user = _context.Users.Find(id);
            if (user == null) return NotFound();
            user.IsActive = !user.IsActive;
            _context.SaveChanges();
            return Ok(new { status = user.IsActive ? "Active" : "Blocked" });
        }

        [HttpDelete("user/{id}")]
        public IActionResult DeleteUser(int id)
        {
            var user = _context.Users.Find(id);
            if (user == null) return NotFound();
            _context.Users.Remove(user);
            _context.SaveChanges();
            return Ok();
        }
        #endregion

        #region Tour Management
        [HttpGet("tours")]
        public IActionResult GetTours() => Ok(_context.Tours.ToList());

        [HttpPost("tour")]
        public IActionResult CreateTour(CreateTourDto dto)
        {
            var tour = new Tour
            {
                Title = dto.Title,
                Description = dto.Description,
                DurationDays = dto.DurationDays,
                Price = dto.Price,
                StartPoint = dto.StartPoint ?? "Dhaka",
                EndPoint = dto.EndPoint ?? "",
                Itinerary = dto.Itinerary,
                IsTopDestination = dto.IsTopDestination,
                ImageUrl = dto.ImageUrl ?? "",
                StartDate = dto.StartDate == default ? DateTime.UtcNow.AddDays(7) : dto.StartDate,
                Vacancy = dto.Vacancy > 0 ? dto.Vacancy : 20
            };
            _context.Tours.Add(tour);
            _context.SaveChanges();
            return Ok(tour);
        }

        [HttpPut("tour/{id}")]
        public IActionResult UpdateTour(int id, CreateTourDto dto)
        {
            var tour = _context.Tours.Find(id);
            if (tour == null) return NotFound();
            
            tour.Title = dto.Title;
            tour.Description = dto.Description;
            tour.DurationDays = dto.DurationDays;
            tour.Price = dto.Price;
            tour.StartPoint = dto.StartPoint ?? tour.StartPoint;
            tour.EndPoint = dto.EndPoint ?? tour.EndPoint;
            tour.Itinerary = dto.Itinerary;
            tour.IsTopDestination = dto.IsTopDestination;
            tour.ImageUrl = dto.ImageUrl ?? tour.ImageUrl;
            tour.StartDate = dto.StartDate;
            tour.Vacancy = dto.Vacancy;
            
            _context.SaveChanges();
            return Ok(tour);
        }

        [HttpDelete("tour/{id}")]
        public IActionResult DeleteTour(int id)
        {
            var tour = _context.Tours.Find(id);
            if (tour == null) return NotFound();
            _context.Tours.Remove(tour);
            _context.SaveChanges();
            return Ok();
        }

        [HttpPut("tour/{id}/toggle-top")]
        public IActionResult ToggleTopDestination(int id)
        {
            var tour = _context.Tours.Find(id);
            if (tour == null) return NotFound();
            tour.IsTopDestination = !tour.IsTopDestination;
            _context.SaveChanges();
            return Ok(new { isTopDestination = tour.IsTopDestination });
        }
        #endregion

        #region Hotel Management
        [HttpGet("hotels")]
        public IActionResult GetHotels() => Ok(_context.Hotels.ToList());

        [HttpPost("hotel")]
        public IActionResult CreateHotel(CreateHotelDto dto)
        {
            var hotel = new Hotel
            {
                Name = dto.Name,
                Location = dto.Location,
                Description = dto.Description,
                ImageUrl = dto.ImageUrl ?? "",
                Amenities = dto.Amenities,
                PricePerNight = dto.PricePerNight,
                AvailableRooms = dto.AvailableRooms,
                IsFeatured = dto.IsFeatured
            };
            _context.Hotels.Add(hotel);
            _context.SaveChanges();

            _context.Rooms.Add(new Room
            {
                HotelId = hotel.Id,
                Type = "Standard Room",
                Price = dto.PricePerNight,
                AvailableRooms = dto.AvailableRooms
            });
            _context.SaveChanges();
            return Ok(hotel);
        }

        [HttpPut("hotel/{id}")]
        public IActionResult UpdateHotel(int id, CreateHotelDto dto)
        {
            var hotel = _context.Hotels.Find(id);
            if (hotel == null) return NotFound();

            hotel.Name = dto.Name;
            hotel.Location = dto.Location;
            hotel.Description = dto.Description;
            hotel.PricePerNight = dto.PricePerNight;
            hotel.ImageUrl = dto.ImageUrl ?? hotel.ImageUrl;
            hotel.Amenities = dto.Amenities ?? hotel.Amenities;
            hotel.IsFeatured = dto.IsFeatured;
            hotel.AvailableRooms = dto.AvailableRooms;

            var room = _context.Rooms.FirstOrDefault(r => r.HotelId == id);
            if (room != null)
            {
                room.AvailableRooms = dto.AvailableRooms;
                room.Price = dto.PricePerNight;
            }
            else
            {
                _context.Rooms.Add(new Room
                {
                    HotelId = hotel.Id,
                    Type = "Standard Room",
                    Price = dto.PricePerNight,
                    AvailableRooms = dto.AvailableRooms
                });
            }

            _context.SaveChanges();
            return Ok(hotel);
        }

        [HttpDelete("hotel/{id}")]
        public IActionResult DeleteHotel(int id)
        {
            var hotel = _context.Hotels.Find(id);
            if (hotel == null) return NotFound();
            _context.Hotels.Remove(hotel);
            _context.SaveChanges();
            return Ok();
        }

        [HttpPut("hotel/{id}/toggle-featured")]
        public IActionResult ToggleFeaturedHotel(int id)
        {
            var hotel = _context.Hotels.Find(id);
            if (hotel == null) return NotFound();
            hotel.IsFeatured = !hotel.IsFeatured;
            _context.SaveChanges();
            return Ok(new { isFeatured = hotel.IsFeatured });
        }
        #endregion

        #region Flight Management
        [HttpGet("flights")]
        public IActionResult GetFlights() =>
            Ok(_context.Flights
                .Select(f => new
                {
                    f.Id,
                    f.Airline,
                    f.From,
                    f.To,
                    f.DepartureTime,
                    f.ArrivalTime,
                    f.Price,
                    f.AvailableSeats,
                    f.IsPopular,
                    SeatClasses = f.SeatClasses
                        .Select(s => new { s.Id, s.ClassName, s.AvailableSeats, s.Price })
                        .ToList()
                })
                .ToList());

        [HttpPost("flight")]
        public IActionResult CreateFlight(CreateFlightDto dto, [FromServices] FlightService flightService)
        {
            if (dto.SeatClasses == null || dto.SeatClasses.Count == 0)
                return BadRequest(new { error = "Add at least one seat class with seats and price." });

            flightService.AddFlight(dto);
            var flightId = _context.Flights.OrderByDescending(f => f.Id).Select(f => f.Id).First();
            return Ok(BuildFlightResponse(flightId));
        }

        [HttpPut("flight/{id}")]
        public IActionResult UpdateFlight(int id, CreateFlightDto dto, [FromServices] FlightService flightService)
        {
            var flight = _context.Flights.Find(id);
            if (flight == null) return NotFound();

            if (dto.SeatClasses == null || dto.SeatClasses.Count == 0)
                return BadRequest(new { error = "Add at least one seat class with seats and price." });

            flight.Airline = dto.Airline;
            flight.From = dto.From;
            flight.To = dto.To;
            flight.DepartureTime = dto.DepartureTime;
            flight.ArrivalTime = dto.ArrivalTime;
            flight.IsPopular = dto.IsPopular;

            flightService.UpsertSeatClasses(id, dto.SeatClasses);
            _context.SaveChanges();
            return Ok(BuildFlightResponse(id));
        }

        private object BuildFlightResponse(int flightId)
        {
            var f = _context.Flights.First(x => x.Id == flightId);
            var classes = _context.FlightSeatClasses
                .Where(s => s.FlightId == flightId)
                .Select(s => new { s.Id, s.ClassName, s.AvailableSeats, s.Price })
                .ToList();

            return new
            {
                f.Id,
                f.Airline,
                f.From,
                f.To,
                f.DepartureTime,
                f.ArrivalTime,
                f.Price,
                f.AvailableSeats,
                f.IsPopular,
                SeatClasses = classes
            };
        }

        [HttpDelete("flight/{id}")]
        public IActionResult DeleteFlight(int id)
        {
            var flight = _context.Flights.Find(id);
            if (flight == null) return NotFound();
            _context.Flights.Remove(flight);
            _context.SaveChanges();
            return Ok();
        }

        [HttpPut("flight/{id}/toggle-popular")]
        public IActionResult TogglePopularFlight(int id)
        {
            var flight = _context.Flights.Find(id);
            if (flight == null) return NotFound();
            flight.IsPopular = !flight.IsPopular;
            _context.SaveChanges();
            return Ok(new { isPopular = flight.IsPopular });
        }
        #endregion



        [HttpPost("upload")]
        public async Task<IActionResult> Upload(IFormFile file)
        {
            if (file == null || file.Length == 0) return BadRequest("File is empty");
            var path = await _fileService.Upload(file);
            return Ok(new { path });
        }


        [HttpGet("dashboard")]
        public IActionResult Dashboard()
        {
            var totalBookings = _context.FlightBookings.Count() + 
                               _context.HotelBookings.Count() + 
                               _context.TourBookings.Count();

            var flightRevenue = _context.FlightBookings.Sum(b => (decimal?)b.TotalPrice) ?? 0;
            var hotelRevenue = _context.HotelBookings.Sum(b => (decimal?)b.TotalPrice) ?? 0;
            
            // Join with Tours to get the price for each tour booking
            var tourRevenue = _context.TourBookings.Sum(b => (decimal?)b.TotalPrice) ?? 0;

            var totalRevenue = flightRevenue + hotelRevenue + tourRevenue;

            return Ok(new
            {
                users = _context.Users.Count(),
                flights = _context.Flights.Count(),
                hotels = _context.Hotels.Count(),
                tours = _context.Tours.Count(),
                totalBookings,
                totalRevenue
            });
        }

        #region Booking Oversight
        [HttpGet("bookings/hotels")]
        public IActionResult GetHotelBookings() => 
            Ok(_context.HotelBookings.Include(b => b.Room).ToList());

        [HttpGet("bookings/flights")]
        public IActionResult GetFlightBookings() => 
            Ok(_context.FlightBookings.Include(b => b.Flight).ToList());

        [HttpGet("bookings/tours")]
        public IActionResult GetTourBookings() => 
            Ok(_context.TourBookings.ToList());
        #endregion

        #region Super Admin Management
        [HttpGet("admins")]
        [Authorize(Roles = "SuperAdmin")]
        public IActionResult GetAdmins() => Ok(_context.Admins.ToList());

        [HttpPost("admins")]
        [Authorize(Roles = "SuperAdmin")]
        public IActionResult CreateAdmin(TravelApp.DTOs.Auth.CreateAdminDto dto)
        {
            if (_context.Admins.Any(a => a.Email.ToLower() == dto.Email.ToLower()))
                return BadRequest(new { error = "Admin email already exists" });

            var admin = new Admin
            {
                Name = dto.Name,
                Email = dto.Email,
                Phone = dto.Phone,
                Password = TravelApp.Services.PasswordHasher.Hash(dto.Password),
                Role = dto.Role ?? "Admin"
            };
            _context.Admins.Add(admin);
            _context.SaveChanges();
            return Ok(admin);
        }

        [HttpDelete("admins/{id}")]
        [Authorize(Roles = "SuperAdmin")]
        public IActionResult DeleteAdmin(int id)
        {
            var admin = _context.Admins.Find(id);
            if (admin == null) return NotFound();
            
            // Prevent super admin from deleting themselves if needed, but for now just delete
            _context.Admins.Remove(admin);
            _context.SaveChanges();
            return Ok();
        }
        #endregion
    }
}