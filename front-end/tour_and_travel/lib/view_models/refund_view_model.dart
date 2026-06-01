import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/repositories/refund_repository.dart';
import 'notification_view_model.dart';

class RefundViewModel extends GetxController {
  final RefundRepository _refundRepository = RefundRepository();

  var isLoading = false.obs;
  var userRefunds = <dynamic>[].obs;

  Future<bool> createRefundRequest(
    String itemType,
    int bookingId,
    String reason,
  ) async {
    try {
      isLoading(true);

      final data = {
        "itemType": itemType,
        "bookingId": bookingId,
        "reason": reason,
      };

      await _refundRepository.createRefundRequest(data);
      await NotificationViewModel.refreshIfActive();

      Get.snackbar(
        "Success",
        "Refund request submitted successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to submit refund request.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchUserRefundRequests() async {
    try {
      isLoading(true);
      final response = await _refundRepository.getUserRefundRequests();
      userRefunds.value = response;
    } catch (e) {
      userRefunds.value = [];
    } finally {
      isLoading(false);
    }
  }

  var allRefunds = <dynamic>[].obs;

  Future<void> fetchAllRefundRequests() async {
    try {
      isLoading(true);
      final response = await _refundRepository.getAllRefundRequests();
      allRefunds.value = response;
    } catch (e) {
      allRefunds.value = [];
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateRefundStatus(
    int id,
    String status,
    int refundPercentage,
    String? adminFeedback,
  ) async {
    try {
      isLoading(true);

      final data = {
        "status": status,
        "refundPercentage": refundPercentage,
        "adminFeedback": adminFeedback,
      };

      await _refundRepository.updateRefundStatus(id, data);
      await NotificationViewModel.refreshIfActive();

      Get.snackbar(
        "Success",
        "Refund request status updated to $status.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await fetchAllRefundRequests(); // Refresh the list
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update refund status.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading(false);
    }
  }
}
