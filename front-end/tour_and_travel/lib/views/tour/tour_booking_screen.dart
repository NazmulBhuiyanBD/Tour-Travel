import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/tour_view_model.dart';
import '../../view_models/booking_view_model.dart';
import '../../view_models/payment_view_model.dart';
import '../../routes/app_routes.dart';

class TourBookingScreen extends StatefulWidget {
  final int tourId;
  final String title;
  final double price;
  final int vacancy;
  final DateTime? startDate;

  const TourBookingScreen({
    super.key,
    required this.tourId,
    required this.title,
    required this.price,
    this.vacancy = 20,
    this.startDate,
  });

  @override
  State<TourBookingScreen> createState() => _TourBookingScreenState();
}

class _TourBookingScreenState extends State<TourBookingScreen> {
  final TourViewModel _tourViewModel = Get.find<TourViewModel>();
  final PaymentViewModel _paymentViewModel = Get.put(PaymentViewModel());
  int _participants = 1;

  int get _maxParticipants => widget.vacancy.clamp(1, 4);

  double get _total => widget.price * _participants;

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You are booking: ${widget.title}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    if (widget.startDate != null)
                      Text(
                        "Tour starts: ${widget.startDate!.toLocal().toString().substring(0, 10)}",
                        style: const TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    Text(
                      "${widget.vacancy} spots available • \$${widget.price.toStringAsFixed(2)} per person",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Travelers (max 4)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _participants > 1 ? () => setState(() => _participants--) : null,
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                            ),
                            Text("$_participants", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: _participants < _maxParticipants ? () => setState(() => _participants++) : null,
                              icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("\$${_total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
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
                            groupValue: _paymentViewModel.selectedPaymentMethod.value,
                            activeColor: Colors.orange,
                            onChanged: (val) => _paymentViewModel.selectedPaymentMethod.value = val!,
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            title: const Text("PayPal", style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text("Pay securely via PayPal account"),
                            value: "paypal",
                            groupValue: _paymentViewModel.selectedPaymentMethod.value,
                            activeColor: Colors.orange,
                            onChanged: (val) => _paymentViewModel.selectedPaymentMethod.value = val!,
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: (_tourViewModel.isLoading.value || _paymentViewModel.isLoading.value)
                      ? null
                      : () async {
                          String transactionId = "TOUR_${DateTime.now().millisecondsSinceEpoch}";
                          bool paymentSuccess = false;

                          if (_paymentViewModel.selectedPaymentMethod.value == "sslcommerz") {
                            paymentSuccess = await _paymentViewModel.processSslCommerzPayment(
                              amount: _total,
                              transactionId: transactionId,
                              productName: "Tour: ${widget.title}",
                            );
                          } else {
                            paymentSuccess = await _paymentViewModel.processPaypalPayment(
                              amount: _total,
                              transactionId: transactionId,
                            );
                          }

                          if (paymentSuccess) {
                            bool success = await _tourViewModel.bookTour(
                              widget.tourId,
                              transactionId,
                              _paymentViewModel.selectedPaymentMethod.value,
                              participantCount: _participants,
                            );
                            if (success) {
                              if (Get.isRegistered<BookingViewModel>()) {
                                Get.find<BookingViewModel>().fetchBookingHistory();
                              }
                              Get.toNamed(Routes.BOOKING_SUCCESS, arguments: {
                                'type': 'Tour',
                                'title': "Tour: ${widget.title}",
                                'price': _total,
                                'quantity': _participants,
                                'transactionId': transactionId,
                              });
                            }
                          }
                        },
                  child: (_tourViewModel.isLoading.value || _paymentViewModel.isLoading.value)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Pay & Confirm Booking", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
