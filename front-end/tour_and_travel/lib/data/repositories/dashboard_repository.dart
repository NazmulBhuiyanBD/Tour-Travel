import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';
import 'package:tour_and_travel/data/api/api_client.dart';

class DashboardRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getTopDestinations() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.toursTop);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPopularAirlines() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.flightsPopular);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getFeaturedHotels() async {
    try {
      return await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.hotelsFeatured);
    } catch (e) {
      rethrow;
    }
  }
}
