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
    [Authorize(Roles = "Admin")]
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
            var validationError = ValidateTourInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });

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
                Vacancy = dto.Vacancy
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

            var validationError = ValidateTourInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });
            
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
        public IActionResult GetHotels() => Ok(_context.Hotels.Include(h => h.Rooms).ToList());

        [HttpPost("hotel")]
        public IActionResult CreateHotel(CreateHotelDto dto)
        {
            var validationError = ValidateHotelInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });

            var hotel = new Hotel
            {
                Name = dto.Name,
                Location = dto.Location,
                Description = dto.Description,
                ImageUrl = dto.ImageUrl ?? "",
                Amenities = dto.Amenities,
                PricePerNight = dto.PricePerNight,
                AvailableRooms = dto.AvailableRooms,
                IsFeatured = dto.IsFeatured,
                ContactInfo = dto.ContactInfo ?? ""
            };
            _context.Hotels.Add(hotel);
            _context.SaveChanges();

            _context.Rooms.Add(new Room
            {
                HotelId = hotel.Id,
                Type = dto.RoomType,
                BedType = dto.BedType,
                ViewType = dto.ViewType,
                IsAc = dto.IsAc,
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

            var validationError = ValidateHotelInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });

            hotel.Name = dto.Name;
            hotel.Location = dto.Location;
            hotel.Description = dto.Description;
            hotel.PricePerNight = dto.PricePerNight;
            hotel.ImageUrl = dto.ImageUrl ?? hotel.ImageUrl;
            hotel.Amenities = dto.Amenities ?? hotel.Amenities;
            hotel.IsFeatured = dto.IsFeatured;
            hotel.AvailableRooms = dto.AvailableRooms;
            hotel.ContactInfo = dto.ContactInfo ?? hotel.ContactInfo;

            var room = _context.Rooms.FirstOrDefault(r => r.HotelId == id);
            if (room != null)
            {
                room.AvailableRooms = dto.AvailableRooms;
                room.Price = dto.PricePerNight;
                room.Type = dto.RoomType;
                room.BedType = dto.BedType;
                room.ViewType = dto.ViewType;
                room.IsAc = dto.IsAc;
            }
            else
            {
                _context.Rooms.Add(new Room
                {
                    HotelId = hotel.Id,
                    Type = dto.RoomType,
                    BedType = dto.BedType,
                    ViewType = dto.ViewType,
                    IsAc = dto.IsAc,
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

        // Room management endpoints for Admin
        [HttpGet("hotels/{hotelId}/rooms")]
        public IActionResult GetHotelRooms(int hotelId)
        {
            var rooms = _context.Rooms.Where(r => r.HotelId == hotelId).ToList();
            return Ok(rooms);
        }

        [HttpPost("hotels/{hotelId}/rooms")]
        public IActionResult AddHotelRoom(int hotelId, CreateRoomDto dto)
        {
            var hotel = _context.Hotels.Find(hotelId);
            if (hotel == null) return NotFound("Hotel not found");

            var validationError = ValidateRoomInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });

            var room = new Room
            {
                HotelId = hotelId,
                Type = dto.Type,
                BedType = dto.BedType,
                ViewType = dto.ViewType,
                IsAc = dto.IsAc,
                Price = dto.Price,
                AvailableRooms = dto.AvailableRooms
            };
            _context.Rooms.Add(room);
            _context.SaveChanges();

            RecalculateHotelStats(hotelId);
            return Ok(room);
        }

        [HttpPut("hotels/rooms/{roomId}")]
        public IActionResult UpdateHotelRoom(int roomId, CreateRoomDto dto)
        {
            var room = _context.Rooms.Find(roomId);
            if (room == null) return NotFound("Room not found");

            var validationError = ValidateRoomInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });

            room.Type = dto.Type;
            room.BedType = dto.BedType;
            room.ViewType = dto.ViewType;
            room.IsAc = dto.IsAc;
            room.Price = dto.Price;
            room.AvailableRooms = dto.AvailableRooms;

            _context.SaveChanges();

            RecalculateHotelStats(room.HotelId);
            return Ok(room);
        }

        [HttpDelete("hotels/rooms/{roomId}")]
        public IActionResult DeleteHotelRoom(int roomId)
        {
            var room = _context.Rooms.Find(roomId);
            if (room == null) return NotFound("Room not found");

            int hotelId = room.HotelId;
            _context.Rooms.Remove(room);
            _context.SaveChanges();

            RecalculateHotelStats(hotelId);
            return Ok();
        }

        private void RecalculateHotelStats(int hotelId)
        {
            var hotel = _context.Hotels.Include(h => h.Rooms).FirstOrDefault(h => h.Id == hotelId);
            if (hotel != null)
            {
                if (hotel.Rooms.Any())
                {
                    hotel.AvailableRooms = hotel.Rooms.Sum(r => r.AvailableRooms);
                    hotel.PricePerNight = hotel.Rooms.Min(r => r.Price);
                }
                else
                {
                    hotel.AvailableRooms = 0;
                    hotel.PricePerNight = 0;
                }
                _context.SaveChanges();
            }
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
            var validationError = ValidateFlightInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });

            flightService.AddFlight(dto);
            var flightId = _context.Flights.OrderByDescending(f => f.Id).Select(f => f.Id).First();
            return Ok(BuildFlightResponse(flightId));
        }

        [HttpPut("flight/{id}")]
        public IActionResult UpdateFlight(int id, CreateFlightDto dto, [FromServices] FlightService flightService)
        {
            var flight = _context.Flights.Find(id);
            if (flight == null) return NotFound();

            var validationError = ValidateFlightInput(dto);
            if (validationError != null) return BadRequest(new { error = validationError });

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

        private static string? ValidateTourInput(CreateTourDto dto)
        {
            if (dto.DurationDays <= 0) return "Duration must be greater than zero.";
            if (dto.Price <= 0) return "Tour price must be greater than zero.";
            if (dto.Vacancy <= 0) return "Vacancy must be greater than zero.";
            return null;
        }

        private static string? ValidateHotelInput(CreateHotelDto dto)
        {
            if (dto.PricePerNight <= 0) return "Hotel price must be greater than zero.";
            if (dto.AvailableRooms <= 0) return "Available rooms must be greater than zero.";
            return null;
        }

        private static string? ValidateRoomInput(CreateRoomDto dto)
        {
            if (dto.Price <= 0) return "Room price must be greater than zero.";
            if (dto.AvailableRooms <= 0) return "Room quantity must be greater than zero.";
            return null;
        }

        private static string? ValidateFlightInput(CreateFlightDto dto)
        {
            if (dto.SeatClasses == null || dto.SeatClasses.Count == 0)
                return "Add at least one seat class with seats and price.";

            if (dto.SeatClasses.Any(s => s.AvailableSeats <= 0))
                return "Available seats must be greater than zero.";

            if (dto.SeatClasses.Any(s => s.Price <= 0))
                return "Seat class price must be greater than zero.";

            return null;
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

            var pendingRefunds = _context.RefundRequests.Count(r => r.Status == "Pending");

            return Ok(new
            {
                users = _context.Users.Count(),
                flights = _context.Flights.Count(),
                hotels = _context.Hotels.Count(),
                tours = _context.Tours.Count(),
                totalBookings,
                totalRevenue,
                pendingRefunds
            });
        }

        [HttpGet("revenue-report")]
        public IActionResult GetRevenueReport([FromQuery] DateTime startDate, [FromQuery] DateTime endDate)
        {
            var rangeStart = startDate.Date;
            var rangeEndExclusive = endDate.Date.AddDays(1);

            var flightBookings = _context.FlightBookings
                .Where(b => b.BookingDate >= rangeStart && b.BookingDate < rangeEndExclusive)
                .ToList();

            var hotelBookings = _context.HotelBookings
                .Where(b => b.BookingDate >= rangeStart && b.BookingDate < rangeEndExclusive)
                .ToList();

            var tourBookings = _context.TourBookings
                .Where(b => b.BookingDate >= rangeStart && b.BookingDate < rangeEndExclusive)
                .ToList();

            var refunds = _context.RefundRequests
                .Where(r => r.RequestedAt >= rangeStart && r.RequestedAt < rangeEndExclusive && r.Status == "Approved")
                .ToList();

            var dailyData = new Dictionary<string, dynamic>();

            var currDate = rangeStart;
            while (currDate <= endDate.Date)
            {
                var nextDate = currDate.AddDays(1);
                
                var fb = flightBookings.Where(b => b.BookingDate >= currDate && b.BookingDate < nextDate).ToList();
                var hb = hotelBookings.Where(b => b.BookingDate >= currDate && b.BookingDate < nextDate).ToList();
                var tb = tourBookings.Where(b => b.BookingDate >= currDate && b.BookingDate < nextDate).ToList();
                var rf = refunds.Where(r => r.RequestedAt >= currDate && r.RequestedAt < nextDate).ToList();

                var confirmedCount = fb.Count + hb.Count + tb.Count;
                var dailyGross = fb.Sum(b => b.TotalPrice) + hb.Sum(b => b.TotalPrice) + tb.Sum(b => b.TotalPrice);
                var dailyRefunds = rf.Sum(r => r.RefundAmount);
                var dailyNet = dailyGross - dailyRefunds;

                dailyData[currDate.ToString("yyyy-MM-dd")] = new
                {
                    bookingsCount = confirmedCount,
                    grossRevenue = dailyGross,
                    refunds = dailyRefunds,
                    netRevenue = dailyNet
                };

                currDate = nextDate;
            }

            var totalGross = flightBookings.Sum(b => b.TotalPrice) + hotelBookings.Sum(b => b.TotalPrice) + tourBookings.Sum(b => b.TotalPrice);
            var totalRefunds = refunds.Sum(r => r.RefundAmount);
            var netRevenue = totalGross - totalRefunds;

            return Ok(new
            {
                totalBookings = flightBookings.Count + hotelBookings.Count + tourBookings.Count,
                grossRevenue = totalGross,
                totalRefunds = totalRefunds,
                netRevenue = netRevenue,
                dailyData = dailyData
            });
        }

        #region Booking Oversight
        [HttpGet("bookings/hotels")]
        public IActionResult GetHotelBookings() =>
            Ok(_context.HotelBookings
                .AsNoTracking()
                .Include(b => b.Room)
                .ThenInclude(r => r.Hotel)
                .Select(b => new
                {
                    b.Id,
                    b.UserId,
                    UserName = _context.Users
                        .Where(u => u.Id == b.UserId)
                        .Select(u => u.Name)
                        .FirstOrDefault(),
                    b.RoomId,
                    b.CheckIn,
                    b.CheckOut,
                    b.RoomCount,
                    b.TotalPrice,
                    b.PaymentMethod,
                    b.TransactionId,
                    b.Status,
                    b.BookingDate,
                    Room = b.Room == null ? null : new
                    {
                        b.Room.Id,
                        b.Room.Type,
                        b.Room.BedType,
                        b.Room.ViewType,
                        b.Room.IsAc,
                        b.Room.Price,
                        Hotel = b.Room.Hotel == null ? null : new
                        {
                            b.Room.Hotel.Id,
                            b.Room.Hotel.Name,
                            b.Room.Hotel.Location
                        }
                    }
                })
                .OrderByDescending(b => b.BookingDate)
                .ToList());

        [HttpGet("bookings/flights")]
        public IActionResult GetFlightBookings() =>
            Ok(_context.FlightBookings
                .AsNoTracking()
                .Include(b => b.Flight)
                .Select(b => new
                {
                    b.Id,
                    b.UserId,
                    UserName = _context.Users
                        .Where(u => u.Id == b.UserId)
                        .Select(u => u.Name)
                        .FirstOrDefault(),
                    b.FlightId,
                    b.SeatCount,
                    b.SeatClass,
                    b.TotalPrice,
                    b.PaymentMethod,
                    b.TransactionId,
                    b.Status,
                    b.BookingDate,
                    Flight = b.Flight == null ? null : new
                    {
                        b.Flight.Id,
                        b.Flight.Airline,
                        b.Flight.From,
                        b.Flight.To,
                        b.Flight.DepartureTime,
                        b.Flight.ArrivalTime
                    }
                })
                .OrderByDescending(b => b.BookingDate)
                .ToList());

        [HttpGet("bookings/tours")]
        public IActionResult GetTourBookings() =>
            Ok(_context.TourBookings
                .AsNoTracking()
                .Select(b => new
                {
                    b.Id,
                    b.UserId,
                    UserName = _context.Users
                        .Where(u => u.Id == b.UserId)
                        .Select(u => u.Name)
                        .FirstOrDefault(),
                    b.TourId,
                    b.ParticipantCount,
                    b.TotalPrice,
                    b.PaymentMethod,
                    b.TransactionId,
                    b.Status,
                    b.BookingDate,
                    Tour = _context.Tours
                        .Where(t => t.Id == b.TourId)
                        .Select(t => new
                        {
                            t.Id,
                            t.Title,
                            t.StartPoint,
                            t.EndPoint,
                            t.StartDate,
                            t.DurationDays
                        })
                        .FirstOrDefault()
                })
                .OrderByDescending(b => b.BookingDate)
                .ToList());
        #endregion


    }
}
