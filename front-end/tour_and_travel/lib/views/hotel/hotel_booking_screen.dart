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
  List<dynamic> _roomOptions = [];
  int? _selectedRoomId;
  bool _isCheckingAvailability = false;

  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 4));

  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_hotelViewModel.searchCheckIn.value != null &&
        _hotelViewModel.searchCheckOut.value != null) {
      _checkInDate = _hotelViewModel.searchCheckIn.value!;
      _checkOutDate = _hotelViewModel.searchCheckOut.value!;
      if (_hotelViewModel.searchRoomsCount.value > 1) {
        _roomCount = _hotelViewModel.searchRoomsCount.value;
      }
    } else {
      _checkInDate = DateTime.now().add(const Duration(days: 1));
      _checkOutDate = DateTime.now().add(const Duration(days: 4));
      if (widget.initialNights != null) {
        final nights = widget.initialNights!.clamp(1, _maxNights);
        _checkOutDate = _checkInDate.add(Duration(days: nights));
      }
    }
    _updateControllers();
    _loadAvailability();
  }

  void _updateControllers() {
    _checkInController.text =
        "${_checkInDate.year}-${_checkInDate.month.toString().padLeft(2, '0')}-${_checkInDate.day.toString().padLeft(2, '0')}";
    _checkOutController.text =
        "${_checkOutDate.year}-${_checkOutDate.month.toString().padLeft(2, '0')}-${_checkOutDate.day.toString().padLeft(2, '0')}";
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
      firstDate: isCheckIn
          ? DateTime.now()
          : _checkInDate.add(const Duration(days: 1)),
      lastDate: isCheckIn
          ? DateTime.now().add(const Duration(days: 365))
          : maxCheckOut,
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
      await _loadAvailability();
    }
  }

  Future<void> _loadAvailability() async {
    setState(() => _isCheckingAvailability = true);
    final rooms = await _hotelViewModel.fetchRoomAvailability(
      widget.hotelId,
      "${_checkInController.text}T00:00:00Z",
      "${_checkOutController.text}T00:00:00Z",
    );
    if (!mounted) return;
    setState(() {
      _roomOptions = rooms;
      if (_roomOptions.isNotEmpty &&
          !_roomOptions.any((room) => room['id'] == _selectedRoomId)) {
        _selectedRoomId = _roomOptions.first['id'];
      }
      if (_roomCount > _maxRooms) {
        _roomCount = _maxRooms.clamp(1, 4);
      }
      _isCheckingAvailability = false;
    });
  }

  dynamic get _selectedRoom {
    if (_roomOptions.isEmpty) return null;
    return _roomOptions.firstWhere(
      (room) => room['id'] == _selectedRoomId,
      orElse: () => _roomOptions.first,
    );
  }

  int get _availableRoomsForDates {
    final room = _selectedRoom;
    if (room == null) return widget.availableRooms;
    return (room['availableRooms'] as num?)?.toInt() ?? 0;
  }

  int get _maxRooms => _availableRoomsForDates.clamp(0, 4);

  double get _selectedRoomPrice {
    final room = _selectedRoom;
    return (room?['price'] as num?)?.toDouble() ?? widget.price;
  }

  double get _totalAmount {
    int nights = _checkOutDate.difference(_checkInDate).inDays;
    if (nights <= 0) nights = 1;
    return _selectedRoomPrice * nights * _roomCount;
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
        title: Text(
          widget.hotelName,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Total rooms: ${widget.availableRooms} • Max $_maxNights nights",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              _buildRoomAvailabilitySection(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Number of Rooms (max $_maxRooms)",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _roomCount > 1
                            ? () => setState(() => _roomCount--)
                            : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.teal,
                        ),
                      ),
                      Text(
                        "$_roomCount",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _roomCount < _maxRooms
                            ? () => setState(() => _roomCount++)
                            : null,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Estimation Cost Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.withValues(alpha: 0.1),
                      Colors.teal.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Duration",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "$_totalNights Nights",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Estimated Cost",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "৳${_totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildPaymentOption(
                        value: "sslcommerz",
                        title: "SSLCommerz",
                        subtitle: "Pay via local cards or mobile banking",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    onPressed:
                        (_hotelViewModel.isLoading.value ||
                            _paymentViewModel.isLoading.value ||
                            _isCheckingAvailability ||
                            _maxRooms == 0)
                        ? null
                        : () async {
                            if (_totalNights > _maxNights) {
                              Get.snackbar(
                                "Invalid Stay",
                                "Maximum stay is $_maxNights nights per booking.",
                              );
                              return;
                            }
                            if (_selectedRoomId == null ||
                                _availableRoomsForDates < _roomCount) {
                              Get.snackbar(
                                "Unavailable",
                                "Selected room is not available for these dates.",
                              );
                              return;
                            }

                            String transactionId =
                                "HOTEL_${DateTime.now().millisecondsSinceEpoch}";
                            final paymentSuccess = await _paymentViewModel
                                .processSslCommerzPayment(
                                  amount: _totalAmount,
                                  transactionId: transactionId,
                                  productName: "Hotel: ${widget.hotelName}",
                                );

                            if (paymentSuccess) {
                              bool success = await _hotelViewModel.bookHotel(
                                widget.hotelId,
                                _selectedRoomId!,
                                "${_checkInController.text}T00:00:00Z",
                                "${_checkOutController.text}T00:00:00Z",
                                transactionId,
                                _paymentViewModel.selectedPaymentMethod.value,
                                roomCount: _roomCount,
                              );
                              if (success) {
                                if (Get.isRegistered<BookingViewModel>()) {
                                  Get.find<BookingViewModel>()
                                      .fetchBookingHistory();
                                }
                                Get.toNamed(
                                  Routes.BOOKING_SUCCESS,
                                  arguments: {
                                    'type': 'Hotel',
                                    'title': "Hotel: ${widget.hotelName}",
                                    'price': _totalAmount,
                                    'quantity': _roomCount,
                                    'transactionId': transactionId,
                                  },
                                );
                              }
                            }
                          },
                    child:
                        (_hotelViewModel.isLoading.value ||
                            _paymentViewModel.isLoading.value ||
                            _isCheckingAvailability)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Pay & Confirm Reservation",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    controller.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
  }) {
    final selected = _paymentViewModel.selectedPaymentMethod.value == value;
    return ListTile(
      onTap: () => _paymentViewModel.selectedPaymentMethod.value = value,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? Colors.teal : Colors.grey,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildRoomAvailabilitySection() {
    if (_isCheckingAvailability) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (_roomOptions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.redAccent),
            SizedBox(width: 10),
            Expanded(
              child: Text("No rooms are available for the selected dates."),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Available Room",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          isExpanded: true,
          value: _selectedRoomId,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.meeting_room, color: Colors.teal),
          ),
          items: _roomOptions.map<DropdownMenuItem<int>>((room) {
            final available = (room['availableRooms'] as num?)?.toInt() ?? 0;
            final acLabel = room['isAc'] == false ? 'Non AC' : 'AC';
            return DropdownMenuItem<int>(
              value: room['id'],
              enabled: available > 0,
              child: Text(
                "${room['type'] ?? 'Room'} • ${room['bedType'] ?? 'Bed'} • ${room['viewType'] ?? 'View'} • $acLabel • $available available",
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedRoomId = value;
              if (_roomCount > _maxRooms) {
                _roomCount = _maxRooms.clamp(1, 4);
              }
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          _availableRoomsForDates > 0
              ? "$_availableRoomsForDates rooms available for selected dates • ৳${_selectedRoomPrice.toStringAsFixed(2)} per night"
              : "Selected room is not available for these dates.",
          style: TextStyle(
            color: _availableRoomsForDates > 0 ? Colors.teal : Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
