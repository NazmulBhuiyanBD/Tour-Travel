import '../api/network_api_service.dart';
import '../../core/constant/api_constants.dart';

class RefundRepository {
  final NetworkApiService _apiService = NetworkApiService();

  Future<dynamic> createRefundRequest(Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiService.getPostApiResponse(
        ApiConstants.baseUrl + ApiConstants.refund,
        data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUserRefundRequests() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
        ApiConstants.baseUrl + ApiConstants.refund + '/user',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
