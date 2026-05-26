import 'package:get/get.dart';
import '../data/repositories/payment_repository.dart';
import '../core/services/ssl_commerz_service.dart';

class PaymentViewModel extends GetxController {
  final PaymentRepository _paymentRepository = PaymentRepository();

  var isLoading = false.obs;
  var gatewayUrl = "".obs;
  var selectedPaymentMethod = "sslcommerz".obs;

  Future<bool> initializePayment(num amount) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {'amount': amount};

      final response = await _paymentRepository.initializePayment(data);

      gatewayUrl.value = response['gatewayUrl'];
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> processSslCommerzPayment({
    required double amount,
    required String transactionId,
    String productName = "Booking",
  }) async {
    try {
      isLoading(true);
      return await SslCommerzService.processPayment(
        amount: amount,
        transactionId: transactionId,
        productName: productName,
      );
    } catch (e) {
      Get.snackbar("Error", "Processing Error: ${e.toString()}");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
