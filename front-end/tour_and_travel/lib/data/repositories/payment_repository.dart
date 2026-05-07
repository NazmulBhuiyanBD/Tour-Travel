import 'package:tour_and_travel/core/constant/api_constants.dart';
import 'package:tour_and_travel/data/api/api_client.dart';
import 'package:tour_and_travel/data/api/network_api_service.dart';

class PaymentRepository {
  final BaseApiService _apiService = NetworkApiService();

  Future<dynamic> initializePayment(dynamic data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
          ApiConstants.baseUrl + ApiConstants.paymentInit, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
