import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class TourRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getAllTours() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.tours);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> bookTour(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.bookTour, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
