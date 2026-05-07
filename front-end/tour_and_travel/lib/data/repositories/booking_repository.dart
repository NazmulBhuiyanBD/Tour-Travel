import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class BookingRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getBookingHistory() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.bookingHistory);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
