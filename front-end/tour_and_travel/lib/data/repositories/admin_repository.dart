import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';
import 'package:tour_and_travel/data/api/api_client.dart';

class AdminRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getUsers() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminUsers);
    } catch (e) {
      rethrow;
    }
  }

  // SuperAdmins
  Future<dynamic> getAdmins() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.superAdmins);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createAdmin(dynamic data) async {
    try {
      return await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.superAdmins, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteAdmin(int id) async {
    try {
      return await _apiService.getDeleteApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.superAdmins}/$id");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleUserStatus(int id) async {
    try {
      return await _apiService.getPutApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminToggleUser}$id/toggle-status", {});
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteUser(int id) async {
    try {
      return await _apiService.getDeleteApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminDeleteUser}$id");
    } catch (e) {
      rethrow;
    }
  }

  // Tours
  Future<dynamic> getTours() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminTours);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createTour(dynamic data) async {
    try {
      return await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminTour, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateTour(int id, dynamic data) async {
    try {
      return await _apiService.getPutApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminTour}/$id", data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteTour(int id) async {
    try {
      return await _apiService.getDeleteApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminTour}/$id");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleTopTour(int id) async {
    try {
      return await _apiService.getPutApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminTour}/$id/toggle-top", {});
    } catch (e) {
      rethrow;
    }
  }

  // Hotels
  Future<dynamic> getHotels() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminHotels);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createHotel(dynamic data) async {
    try {
      return await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminHotel, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateHotel(int id, dynamic data) async {
    try {
      return await _apiService.getPutApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminHotel}/$id", data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteHotel(int id) async {
    try {
      return await _apiService.getDeleteApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminHotel}/$id");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> toggleFeaturedHotel(int id) async {
    try {
      return await _apiService.getPutApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminHotel}/$id/toggle-featured", {});
    } catch (e) {
      rethrow;
    }
  }

  // Flights
  Future<dynamic> getFlights() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminFlights);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createFlight(dynamic data) async {
    try {
      return await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminFlight, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateFlight(int id, dynamic data) async {
    try {
      return await _apiService.getPutApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminFlight}/$id", data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteFlight(int id) async {
    try {
      return await _apiService.getDeleteApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminFlight}/$id");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> togglePopularFlight(int id) async {
    try {
      return await _apiService.getPutApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.adminFlight}/$id/toggle-popular", {});
    } catch (e) {
      rethrow;
    }
  }



  // Bookings
  Future<dynamic> getHotelBookings() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminHotelBookings);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getFlightBookings() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminFlightBookings);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getTourBookings() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminTourBookings);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> uploadImage(File file) async {
    try {
      return await _apiService.getMultipartApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminUpload, file.path);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getDashboardStats() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.adminDashboard);
    } catch (e) {
      rethrow;
    }
  }
}
