import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/flight_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../routes/app_routes.dart';

class FlightBookingScreen extends StatelessWidget {
  final int flightId;
  final String airline;
  final double price;
  final FlightController _flightController = Get.find<FlightController>();
  final PaymentController _paymentController = Get.put(PaymentController());
  final TextEditingController _passengersController = TextEditingController(text: '1');

  FlightBookingScreen({
    super.key, 
    required this.flightId, 
    required this.airline, 
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Confirm Booking", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Passenger Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 10),
            Text(
              "Airline: $airline",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _passengersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Number of Seats",
                  prefixIcon: Icon(Icons.person, color: Colors.indigo),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: (value) {
                  // Trigger rebuild to update total price if needed
                },
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Price", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ValueListenableBuilder(
                    valueListenable: _passengersController,
                    builder: (context, value, child) {
                      int seats = int.tryParse(value.text) ?? 1;
                      return Text(
                        "\$${(price * seats).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
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
                    activeColor: Colors.indigo,
                    onChanged: (val) => _paymentController.selectedPaymentMethod.value = val!,
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text("PayPal", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Pay securely via PayPal account"),
                    value: "paypal",
                    groupValue: _paymentController.selectedPaymentMethod.value,
                    activeColor: Colors.indigo,
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
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: (_flightController.isLoading.value || _paymentController.isLoading.value) ? null : () async {
                  int seats = int.tryParse(_passengersController.text) ?? 1;
                  double totalAmount = price * seats;
                  String transactionId = "FLIGHT_${DateTime.now().millisecondsSinceEpoch}";

                  bool paymentSuccess = false;
                  
                  if (_paymentController.selectedPaymentMethod.value == "sslcommerz") {
                    paymentSuccess = await _paymentController.processSslCommerzPayment(
                      amount: totalAmount,
                      transactionId: transactionId,
                      productName: "Flight: $airline",
                    );
                  } else {
                    paymentSuccess = await _paymentController.processPaypalPayment(
                      amount: totalAmount,
                      transactionId: transactionId,
                    );
                  }

                  if (paymentSuccess) {
                    bool success = await _flightController.bookFlight(
                      flightId, 
                      seats, 
                      transactionId, 
                      _paymentController.selectedPaymentMethod.value
                    );
                      if (success) {
                        if (Get.isRegistered<BookingController>()) {
                          Get.find<BookingController>().fetchBookingHistory();
                        }
                        Get.toNamed(Routes.BOOKING_SUCCESS, arguments: 'Flight');
                      }
                    }

                },
                child: (_flightController.isLoading.value || _paymentController.isLoading.value)
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pay & Confirm Booking", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
