import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class HotelRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getAllHotels({String? checkIn, String? checkOut}) async {
    try {
      String url = ApiConstants.baseUrl + ApiConstants.hotels;
      if (checkIn != null && checkOut != null) {
        url += "?checkIn=$checkIn&checkOut=$checkOut";
      }
      dynamic response = await _apiService.getGetApiResponse(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> bookHotel(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
        ApiConstants.baseUrl + ApiConstants.bookHotel,
        data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getRoomAvailability(
    int hotelId,
    String checkInDate,
    String checkOutDate,
  ) async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
        "${ApiConstants.baseUrl}${ApiConstants.hotelAvailability(hotelId)}?checkIn=$checkInDate&checkOut=$checkOutDate",
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
