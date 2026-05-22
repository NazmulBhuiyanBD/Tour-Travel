import '../api/network_api_service.dart';
import '../../core/constant/api_constants.dart';

class NotificationRepository {
  final NetworkApiService _apiService = NetworkApiService();

  Future<dynamic> getUserNotifications() async {
    try {
      dynamic response = await _apiService.getGetApiResponse(
        '${ApiConstants.baseUrl}/Notification',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> markAsRead(int notificationId) async {
    try {
      dynamic response = await _apiService.getPutApiResponse(
        '${ApiConstants.baseUrl}/Notification/$notificationId/read',
        {},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteNotification(int notificationId) async {
    try {
      dynamic response = await _apiService.getDeleteApiResponse(
        '${ApiConstants.baseUrl}/Notification/$notificationId',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
