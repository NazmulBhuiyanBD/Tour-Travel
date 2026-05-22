import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/flight_view_model.dart';
import '../../view_models/booking_view_model.dart';
import '../../view_models/payment_view_model.dart';
import '../../routes/app_routes.dart';

class FlightBookingScreen extends StatefulWidget {
  final int flightId;
  final String airline;
  final double price;

  const FlightBookingScreen({
    super.key,
    required this.flightId,
    required this.airline,
    required this.price,
  });

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  final FlightViewModel _flightViewModel = Get.find<FlightViewModel>();
  final PaymentViewModel _paymentViewModel = Get.put(PaymentViewModel());
  final TextEditingController _passengersController = TextEditingController(text: '1');

  int _seatCount = 1;
  int _maxSeats = 4;
  double _classPrice = 0;

  @override
  void initState() {
    super.initState();
    _classPrice = widget.price;
    _loadSeatClasses();
  }

  Future<void> _loadSeatClasses() async {
    await _flightViewModel.fetchSeatClasses(widget.flightId);
    if (_flightViewModel.seatClasses.isNotEmpty) {
      final first = _flightViewModel.seatClasses.first;
      _flightViewModel.selectedSeatClass.value = first['className'] ?? 'Economy';
      _classPrice = (first['price'] as num?)?.toDouble() ?? widget.price;
      _maxSeats = (first['availableSeats'] as num?)?.toInt() ?? 4;
      if (_maxSeats > 4) _maxSeats = 4;
    }
    setState(() {});
  }

  void _onClassChanged(String className) {
    final sc = _flightViewModel.seatClasses.firstWhere(
      (s) => (s['className'] ?? '').toString() == className,
      orElse: () => {},
    );
    if (sc.isNotEmpty) {
      _classPrice = (sc['price'] as num?)?.toDouble() ?? widget.price;
      final avail = (sc['availableSeats'] as num?)?.toInt() ?? 4;
      _maxSeats = avail > 4 ? 4 : avail;
      if (_seatCount > _maxSeats) _seatCount = _maxSeats;
      _passengersController.text = '$_seatCount';
    }
    _flightViewModel.selectedSeatClass.value = className;
    setState(() {});
  }

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Passenger Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const SizedBox(height: 10),
                    Text("Airline: ${widget.airline}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 20),
                    const Text("Seat Class", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (_flightViewModel.seatClasses.isEmpty) {
                        return const Text("Economy (default)", style: TextStyle(color: Colors.grey));
                      }
                      return Column(
                        children: _flightViewModel.seatClasses.map<Widget>((sc) {
                          final name = sc['className'] ?? 'Economy';
                          final avail = sc['availableSeats'] ?? 0;
                          final price = sc['price'] ?? widget.price;
                          return RadioListTile<String>(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(name),
                            subtitle: Text("$avail seats • \$$price each"),
                            value: name,
                            groupValue: _flightViewModel.selectedSeatClass.value,
                            onChanged: avail > 0 ? (v) => _onClassChanged(v!) : null,
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Seats (max $_maxSeats)", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _seatCount > 1 ? () => setState(() { _seatCount--; _passengersController.text = '$_seatCount'; }) : null,
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.indigo),
                            ),
                            Text("$_seatCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: _seatCount < _maxSeats ? () => setState(() { _seatCount++; _passengersController.text = '$_seatCount'; }) : null,
                              icon: const Icon(Icons.add_circle_outline, color: Colors.indigo),
                            ),
                          ],
                        ),
                      ],
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
                          Text(
                            "\$${(_classPrice * _seatCount).toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
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
                            value: "sslcommerz",
                            groupValue: _paymentViewModel.selectedPaymentMethod.value,
                            activeColor: Colors.indigo,
                            onChanged: (val) => _paymentViewModel.selectedPaymentMethod.value = val!,
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            title: const Text("PayPal", style: TextStyle(fontWeight: FontWeight.w600)),
                            value: "paypal",
                            groupValue: _paymentViewModel.selectedPaymentMethod.value,
                            activeColor: Colors.indigo,
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
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: (_flightViewModel.isLoading.value || _paymentViewModel.isLoading.value)
                      ? null
                      : () async {
                          double totalAmount = _classPrice * _seatCount;
                          String transactionId = "FLIGHT_${DateTime.now().millisecondsSinceEpoch}";
                          bool paymentSuccess = false;

                          if (_paymentViewModel.selectedPaymentMethod.value == "sslcommerz") {
                            paymentSuccess = await _paymentViewModel.processSslCommerzPayment(
                              amount: totalAmount,
                              transactionId: transactionId,
                              productName: "Flight: ${widget.airline}",
                            );
                          } else {
                            paymentSuccess = await _paymentViewModel.processPaypalPayment(
                              amount: totalAmount,
                              transactionId: transactionId,
                            );
                          }

                          if (paymentSuccess) {
                            bool success = await _flightViewModel.bookFlight(
                              widget.flightId,
                              _seatCount,
                              transactionId,
                              _paymentViewModel.selectedPaymentMethod.value,
                              seatClass: _flightViewModel.selectedSeatClass.value,
                            );
                            if (success) {
                              if (Get.isRegistered<BookingViewModel>()) {
                                Get.find<BookingViewModel>().fetchBookingHistory();
                              }
                              Get.toNamed(Routes.BOOKING_SUCCESS, arguments: {
                                'type': 'Flight',
                                'title': "Flight: ${widget.airline}",
                                'price': totalAmount,
                                'quantity': _seatCount,
                                'transactionId': transactionId,
                              });
                            }
                          }
                        },
                  child: (_flightViewModel.isLoading.value || _paymentViewModel.isLoading.value)
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
