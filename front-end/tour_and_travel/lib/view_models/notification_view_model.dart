import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../data/repositories/notification_repository.dart';

class NotificationViewModel extends GetxController with WidgetsBindingObserver {
  final NotificationRepository _repository = NotificationRepository();

  var isLoading = false.obs;
  var notifications = <dynamic>[].obs;
  var unreadCount = 0.obs;
  Timer? _refreshTimer;
  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchNotifications(showError: false);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchNotifications(showLoader: false, showError: false);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchNotifications(showLoader: false, showError: false);
    }
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> fetchNotifications({
    bool showLoader = true,
    bool showError = true,
  }) async {
    if (_isFetching) return;

    try {
      _isFetching = true;
      if (showLoader) {
        isLoading(true);
      }
      final response = await _repository.getUserNotifications();
      if (response != null && response is List) {
        notifications.assignAll(response);
        _updateUnreadCount();
      }
    } catch (e) {
      if (showError) {
        Get.snackbar("Error", "Failed to fetch notifications: $e");
      }
    } finally {
      _isFetching = false;
      if (showLoader) {
        isLoading(false);
      }
    }
  }

  static Future<void> refreshIfActive() async {
    if (Get.isRegistered<NotificationViewModel>()) {
      await Get.find<NotificationViewModel>().fetchNotifications(
        showLoader: false,
        showError: false,
      );
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final index = notifications.indexWhere(
        (element) => element['id'] == notificationId,
      );
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
      final unreadNotifications = notifications
          .where((item) => item['isRead'] == false)
          .toList();
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
    unreadCount.value = notifications
        .where((item) => item['isRead'] == false)
        .length;
  }
}
