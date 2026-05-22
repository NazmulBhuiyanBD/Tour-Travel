import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class ReviewRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> getReviews(String itemType, int itemId) async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          '${ApiConstants.baseUrl}${ApiConstants.getReviews}/$itemType/$itemId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUserReviews() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.userReviews);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addReview(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.addReview, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
