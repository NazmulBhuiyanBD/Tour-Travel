import 'package:get/get.dart';

class SslCommerzService {
  static Future<bool> processPayment({
    required double amount,
    required String transactionId,
    String productName = "Booking",
    String productCategory = "Travel",
  }) async {
    Get.snackbar(
      "Unsupported Platform",
      "SSLCommerz mobile SDK is not available on Chrome/Web.",
    );
    return false;
  }
}
