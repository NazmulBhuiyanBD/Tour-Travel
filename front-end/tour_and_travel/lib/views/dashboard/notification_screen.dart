import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../view_models/notification_view_model.dart';
import '../../core/constant/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationViewModel _viewModel = Get.put(NotificationViewModel());

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Obx(() {
            if (_viewModel.unreadCount.value > 0) {
              return TextButton(
                onPressed: () => _viewModel.markAllAsRead(),
                child: const Text(
                  "Mark all read",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
      body: Obx(() {
        if (_viewModel.isLoading.value && _viewModel.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_viewModel.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_none_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "All Caught Up!",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You have no notifications at the moment.",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _viewModel.fetchNotifications(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: _viewModel.notifications.length,
            itemBuilder: (context, index) {
              final notification = _viewModel.notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        );
      }),
    );
  }

  IconData _getIconForNotification(String title) {
    final t = title.toLowerCase();
    if (t.contains('login')) return Icons.login_rounded;
    if (t.contains('book')) return Icons.confirmation_number_outlined;
    if (t.contains('refund')) return Icons.monetization_on_outlined;
    if (t.contains('support') || t.contains('ticket') || t.contains('chat')) return Icons.support_agent_outlined;
    return Icons.notifications_active_outlined;
  }

  Color _getColorForNotification(String title) {
    final t = title.toLowerCase();
    if (t.contains('login')) return Colors.amber.shade800;
    if (t.contains('book')) return Colors.green.shade600;
    if (t.contains('refund')) return Colors.red.shade600;
    if (t.contains('support') || t.contains('ticket') || t.contains('chat')) return Colors.blue.shade600;
    return Colors.grey.shade600;
  }

  Widget _buildNotificationCard(dynamic notification) {
    final bool isRead = notification['isRead'] ?? false;
    final int id = notification['id'] ?? 0;
    final String title = notification['title'] ?? 'Notification';
    final String message = notification['message'] ?? '';
    final String createdAtStr = notification['createdAt'] ?? '';
    
    String formattedTime = 'N/A';
    if (createdAtStr.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(createdAtStr).toLocal();
        formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(parsedDate);
      } catch (e) {
        formattedTime = createdAtStr;
      }
    }

    final Color themeColor = _getColorForNotification(title);
    final IconData themeIcon = _getIconForNotification(title);

    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _viewModel.deleteNotification(id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF3F5FC),
          borderRadius: BorderRadius.circular(16),
          border: isRead 
              ? Border.all(color: Colors.grey.shade100, width: 1.5)
              : Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!isRead) {
              _viewModel.markNotificationAsRead(id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon indicator
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    themeIcon,
                    color: themeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isRead ? Colors.grey.shade600 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
