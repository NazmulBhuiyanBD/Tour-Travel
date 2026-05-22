import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/view_models/booking_view_model.dart';
import 'package:tour_and_travel/routes/app_routes.dart';
import '../../view_models/hotel_view_model.dart';
import '../../view_models/payment_view_model.dart';

class HotelBookingScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;
  final double price;

  final int availableRooms;
  final int? initialNights;

  const HotelBookingScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.price,
    this.availableRooms = 10,
    this.initialNights,
  });

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  static const int _maxNights = 7;

  final HotelViewModel _hotelViewModel = Get.find<HotelViewModel>();
  final PaymentViewModel _paymentViewModel = Get.put(PaymentViewModel());
  int _roomCount = 1;

  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 4));
  
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialNights != null) {
      final nights = widget.initialNights!.clamp(1, _maxNights);
      _checkOutDate = _checkInDate.add(Duration(days: nights));
    }
    _updateControllers();
  }

  void _updateControllers() {
    _checkInController.text = "${_checkInDate.year}-${_checkInDate.month.toString().padLeft(2, '0')}-${_checkInDate.day.toString().padLeft(2, '0')}";
    _checkOutController.text = "${_checkOutDate.year}-${_checkOutDate.month.toString().padLeft(2, '0')}-${_checkOutDate.day.toString().padLeft(2, '0')}";
  }

  void _clampCheckOutDate() {
    final minCheckOut = _checkInDate.add(const Duration(days: 1));
    final maxCheckOut = _checkInDate.add(const Duration(days: _maxNights));
    if (_checkOutDate.isBefore(minCheckOut)) {
      _checkOutDate = minCheckOut;
    } else if (_checkOutDate.isAfter(maxCheckOut)) {
      _checkOutDate = maxCheckOut;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final maxCheckOut = _checkInDate.add(const Duration(days: _maxNights));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: isCheckIn ? DateTime.now() : _checkInDate.add(const Duration(days: 1)),
      lastDate: isCheckIn ? DateTime.now().add(const Duration(days: 365)) : maxCheckOut,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.teal),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          _clampCheckOutDate();
        } else {
          _checkOutDate = picked;
        }
        _updateControllers();
      });
    }
  }

  int get _maxRooms => widget.availableRooms.clamp(1, 4);

  double get _totalAmount {
    int nights = _checkOutDate.difference(_checkInDate).inDays;
    if (nights <= 0) nights = 1;
    return widget.price * nights * _roomCount;
  }

  int get _totalNights {
    int nights = _checkOutDate.difference(_checkInDate).inDays;
    return nights > 0 ? nights : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.hotelName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Book your stay",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              Text(
                "Price per night: \$${widget.price.toStringAsFixed(2)} • ${widget.availableRooms} rooms available • Max $_maxNights nights",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Number of Rooms (max 4)", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _roomCount > 1 ? () => setState(() => _roomCount--) : null,
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.teal),
                      ),
                      Text("$_roomCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: _roomCount < _maxRooms ? () => setState(() => _roomCount++) : null,
                        icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildDateField(
                controller: _checkInController, 
                label: "Check-In Date", 
                icon: Icons.calendar_today,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 20),
              _buildDateField(
                controller: _checkOutController, 
                label: "Check-Out Date", 
                icon: Icons.event_available,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 30),
              
              // Estimation Cost Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.withOpacity(0.1), Colors.teal.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Duration", style: TextStyle(color: Colors.black54)),
                        Text("$_totalNights Nights", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Estimated Cost", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${_totalAmount.toStringAsFixed(2)}", 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              const Text(
                "Select Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
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
                      groupValue: _paymentViewModel.selectedPaymentMethod.value,
                      activeColor: Colors.teal,
                      onChanged: (val) => _paymentViewModel.selectedPaymentMethod.value = val!,
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text("PayPal", style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text("Pay securely via PayPal account"),
                      value: "paypal",
                      groupValue: _paymentViewModel.selectedPaymentMethod.value,
                      activeColor: Colors.teal,
                      onChanged: (val) => _paymentViewModel.selectedPaymentMethod.value = val!,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: (_hotelViewModel.isLoading.value || _paymentViewModel.isLoading.value) ? null : () async {
                    if (_totalNights > _maxNights) {
                      Get.snackbar("Invalid Stay", "Maximum stay is $_maxNights nights per booking.");
                      return;
                    }

                    String transactionId = "HOTEL_${DateTime.now().millisecondsSinceEpoch}";
                    bool paymentSuccess = false;
                    
                    if (_paymentViewModel.selectedPaymentMethod.value == "sslcommerz") {
                      paymentSuccess = await _paymentViewModel.processSslCommerzPayment(
                        amount: _totalAmount,
                        transactionId: transactionId,
                        productName: "Hotel: ${widget.hotelName}",
                      );
                    } else {
                      paymentSuccess = await _paymentViewModel.processPaypalPayment(
                        amount: _totalAmount,
                        transactionId: transactionId,
                      );
                    }
    
                    if (paymentSuccess) {
                      bool success = await _hotelViewModel.bookHotel(
                        widget.hotelId,
                        "${_checkInController.text}T00:00:00Z",
                        "${_checkOutController.text}T00:00:00Z",
                        transactionId,
                        _paymentViewModel.selectedPaymentMethod.value,
                        roomCount: _roomCount,
                      );
                      if (success) {
                        if (Get.isRegistered<BookingViewModel>()) {
                          Get.find<BookingViewModel>().fetchBookingHistory();
                        }
                        Get.toNamed(Routes.BOOKING_SUCCESS, arguments: {
                          'type': 'Hotel',
                          'title': "Hotel: ${widget.hotelName}",
                          'price': _totalAmount,
                          'quantity': _roomCount,
                          'transactionId': transactionId,
                        });
                      }
                    }
                  },
                  child: (_hotelViewModel.isLoading.value || _paymentViewModel.isLoading.value)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Pay & Confirm Reservation", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({required TextEditingController controller, required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text(controller.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
