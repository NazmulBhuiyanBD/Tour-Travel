import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tour_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../routes/app_routes.dart';

class TourBookingScreen extends StatelessWidget {
  final int tourId;
  final String title;
  final double price;
  final TourController _tourController = Get.find<TourController>();
  final PaymentController _paymentController = Get.put(PaymentController());

  TourBookingScreen({super.key, required this.tourId, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Book Tour", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You are booking: $title",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 10),
            Text(
              "Package Price: \$${price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 30),
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 10),
            Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text("SSLCommerz", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Pay via local cards or mobile banking"),
                    value: "sslcommerz",
                    groupValue: _paymentController.selectedPaymentMethod.value,
                    activeColor: Colors.orange,
                    onChanged: (val) => _paymentController.selectedPaymentMethod.value = val!,
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text("PayPal", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Pay securely via PayPal account"),
                    value: "paypal",
                    groupValue: _paymentController.selectedPaymentMethod.value,
                    activeColor: Colors.orange,
                    onChanged: (val) => _paymentController.selectedPaymentMethod.value = val!,
                  ),
                ],
              ),
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: (_tourController.isLoading.value || _paymentController.isLoading.value) ? null : () async {
                  String transactionId = "TOUR_${DateTime.now().millisecondsSinceEpoch}";

                  bool paymentSuccess = false;
                  
                  if (_paymentController.selectedPaymentMethod.value == "sslcommerz") {
                    paymentSuccess = await _paymentController.processSslCommerzPayment(
                      amount: price,
                      transactionId: transactionId,
                      productName: "Tour: $title",
                    );
                  } else {
                    paymentSuccess = await _paymentController.processPaypalPayment(
                      amount: price,
                      transactionId: transactionId,
                    );
                  }

                  if (paymentSuccess) {
                    bool success = await _tourController.bookTour(
                      tourId,
                      transactionId,
                      _paymentController.selectedPaymentMethod.value
                    );
                    if (success) {
                      if (Get.isRegistered<BookingController>()) {
                        Get.find<BookingController>().fetchBookingHistory();
                      }
                      Get.toNamed(Routes.BOOKING_SUCCESS, arguments: 'Tour');
                    }
                  }
                },
                child: (_tourController.isLoading.value || _paymentController.isLoading.value) 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pay & Confirm Reservation", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
