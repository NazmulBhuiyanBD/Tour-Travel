import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/repositories/refund_repository.dart';

class RefundViewModel extends GetxController {
  final RefundRepository _refundRepository = RefundRepository();

  var isLoading = false.obs;
  var userRefunds = <dynamic>[].obs;

  Future<bool> createRefundRequest(String itemType, int bookingId, String reason) async {
    try {
      isLoading(true);
      
      final data = {
        "itemType": itemType,
        "bookingId": bookingId,
        "reason": reason
      };

      await _refundRepository.createRefundRequest(data);
      
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
}
