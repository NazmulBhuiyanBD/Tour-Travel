import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/core/.env/config.dart';

class SslCommerzService {
  static Future<bool> processPayment({
    required double amount,
    required String transactionId,
    String productName = "Booking",
    String productCategory = "Travel",
  }) async {
    try {
      final sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          store_id: SslcommerzConfig.storeId,
          store_passwd: SslcommerzConfig.pass,
          currency: SSLCurrencyType.BDT,
          total_amount: amount,
          tran_id: transactionId,
          product_category: productCategory,
          sdkType: SSLCSdkType.TESTBOX,
        ),
      );

      final SSLCTransactionInfoModel result = await sslcommerz.payNow();

      return _handleResult(result);
    } catch (e) {
      Get.snackbar("Payment Cancelled", "Payment process was interrupted");
      return false;
    }
  }

  static bool _handleResult(SSLCTransactionInfoModel result) {
    switch (result.status?.toLowerCase()) {
      case "valid":
      case "success":
        Get.snackbar("Success", "Payment Successful: ৳${result.amount}");
        return true;
      case "failed":
        Get.snackbar("Failed", "Payment Failed");
        return false;
      case "closed":
        Get.snackbar("Cancelled", "Payment Cancelled");
        return false;
      default:
        Get.snackbar("Unknown", "Unknown status: ${result.status}");
        return false;
    }
  }
}
