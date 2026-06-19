import 'package:flutter/foundation.dart';

import 'package:tour_and_travel/core/utils/platform_info.dart';

class ApiConstants {
  static String baseUrl = !kIsWeb && PlatformInfo.isAndroid
      ? 'http://10.0.2.2:5198/api'
      : 'http://127.0.0.1:5198/api';

  static String get mediaBaseUrl => baseUrl.replaceAll('/api', '');

  // Auth Endpoints
  static const String login = '/Auth/login';
  static const String adminLogin = '/Auth/admin-login';
  static const String register = '/Auth/register';
  static const String verifyEmail = '/Auth/verify-email';
  static const String forgotPassword = '/Auth/forgot-password';
  static const String resetPassword = '/Auth/reset-password';

  // Tour Endpoints
  static const String tours = '/Tour';
  static const String addTour = '/Tour/add';
  static const String bookTour = '/Tour/book';

  // Hotel Endpoints
  static const String hotels = '/Hotel';
  static const String addHotel = '/Hotel/add';
  static const String bookHotel = '/Hotel/book';
  static String hotelAvailability(int hotelId) =>
      '/Hotel/$hotelId/availability';

  // Flight Endpoints
  static const String flights = '/Flight';
  static const String addFlight = '/Flight/add';
  static const String bookFlight = '/Flight/book';
  static const String flightsPopular = '/Flight/popular';
  static String flightSeatClasses(int flightId) =>
      '/Flight/$flightId/seat-classes';

  // Specific Featured Endpoints
  static const String toursTop = '/Tour/top';
  static const String hotelsFeatured = '/Hotel/featured';

  // User Endpoints
  static const String profile = '/User/profile';
  static const String updateProfile = '/User/update';
  static const String bookings = '/User/bookings';

  // Booking Endpoints
  static const String bookingHistory = '/Booking/history';

  // Payment Endpoints
  static const String paymentInit = '/Payment/init';

  // Chat Endpoints
  static const String chatHistory = '/Chat/history';
  static const String chatUsers = '/Chat/users';

  // Support Endpoints
  static const String createTicket = '/Support/ticket';
  static const String userTickets = '/Support/tickets/user'; // append /{userId}
  static const String adminTickets = '/Support/tickets';
  static const String ticketDetails = '/Support/ticket'; // append /{ticketId}
  static const String sendMessage =
      '/Support/ticket'; // append /{ticketId}/message
  static const String closeTicket =
      '/Support/ticket'; // append /{ticketId}/close
  static const String supportUpload = '/Support/upload';

  // Admin Endpoints
  static const String adminDashboard = '/Admin/dashboard';
  static const String adminUsers = '/Admin/users';
  static const String adminToggleUser =
      '/Admin/user/'; // append {id}/toggle-status
  static const String adminDeleteUser = '/Admin/user/'; // append {id}

  static const String adminTours = '/Admin/tours';
  static const String adminTour = '/Admin/tour'; // append /{id} for PUT/DELETE

  static const String adminHotels = '/Admin/hotels';
  static const String adminHotel =
      '/Admin/hotel'; // append /{id} for PUT/DELETE

  static const String adminFlights = '/Admin/flights';
  static const String adminFlight =
      '/Admin/flight'; // append /{id} for PUT/DELETE

  static const String adminHotelBookings = '/Admin/bookings/hotels';
  static const String adminFlightBookings = '/Admin/bookings/flights';
  static const String adminTourBookings = '/Admin/bookings/tours';
  static const String adminUpload = '/Admin/upload';

  // Password Change
  static const String changePassword = '/Auth/change-password';

  // Review Endpoints
  static const String addReview = '/Review';
  static const String getReviews = '/Review'; // append /{itemType}/{itemId}
  static const String userReviews = '/Review/user';

  // Refund Endpoints
  static const String refund = '/Refund';
}
