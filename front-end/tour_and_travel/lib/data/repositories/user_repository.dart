import '../../core/constant/api_constants.dart';
import '../api/network_api_service.dart';

class UserRepository {
  final NetworkApiService _apiService = NetworkApiService();

  Future<dynamic> updateProfile(dynamic data) async {
    try {
      dynamic response = await _apiService.getPutApiResponse(
          ApiConstants.baseUrl + ApiConstants.updateProfile, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getProfile() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
          ApiConstants.baseUrl + ApiConstants.profile);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
