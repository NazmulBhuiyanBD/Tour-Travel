import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';

class PaymentGatewayScreen extends StatelessWidget {
  final num amount;
  final PaymentController _paymentController = Get.put(PaymentController());

  PaymentGatewayScreen({super.key, required this.amount}) {
    _paymentController.initializePayment(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Secure Checkout", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (_paymentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                Text(
                  "Total amount due: \$${amount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!)
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "SSLCOMMERZ SANDBOX",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text("Redirecting to: ${_paymentController.gatewayUrl.value}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      Get.snackbar("Payment Success", "Simulated mock payment completed via SSLCommerz!");
                      Future.delayed(const Duration(seconds: 2), () {
                        Get.until((route) => route.isFirst);
                      });
                    },
                    child: const Text("Simulate Payment Details", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
