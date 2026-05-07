import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class HotelRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getAllHotels() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.hotels);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> bookHotel(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.bookHotel, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
