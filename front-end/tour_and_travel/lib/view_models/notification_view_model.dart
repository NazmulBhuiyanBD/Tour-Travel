import 'package:get/get.dart';
import '../data/repositories/notification_repository.dart';

class NotificationViewModel extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  var isLoading = false.obs;
  var notifications = <dynamic>[].obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      final response = await _repository.getUserNotifications();
      if (response != null && response is List) {
        notifications.value = response;
        _updateUnreadCount();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch notifications: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final index = notifications.indexWhere((element) => element['id'] == notificationId);
      if (index != -1) {
        notifications[index]['isRead'] = true;
        notifications.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to mark notification as read: $e");
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      notifications.removeWhere((element) => element['id'] == notificationId);
      _updateUnreadCount();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete notification: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading(true);
      final unreadNotifications = notifications.where((item) => item['isRead'] == false).toList();
      for (var item in unreadNotifications) {
        final id = item['id'];
        if (id != null) {
          await _repository.markAsRead(id);
          item['isRead'] = true;
        }
      }
      notifications.refresh();
      _updateUnreadCount();
      Get.snackbar("Success", "All notifications marked as read.");
    } catch (e) {
      Get.snackbar("Error", "Failed to mark all as read: $e");
    } finally {
      isLoading(false);
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((item) => item['isRead'] == false).length;
  }
}
