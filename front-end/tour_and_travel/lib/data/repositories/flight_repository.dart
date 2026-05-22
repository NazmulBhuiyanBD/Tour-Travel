import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class FlightRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getAllFlights() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.flights);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> searchFlights(String from, String to) async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          "${ApiConstants.baseUrl}${ApiConstants.flights}/search?from=$from&to=$to");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSeatClasses(int flightId) async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.flightSeatClasses(flightId));
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> bookFlight(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.bookFlight, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
