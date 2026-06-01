import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/core/utils/positive_number_input_formatter.dart';
import '../../view_models/admin_management_view_model.dart';

class AdminFlightManageScreen extends StatelessWidget {
  const AdminFlightManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminManagementViewModel());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F51B5),
        onPressed: () => _showFlightForm(context, controller),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1A1F36),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Air Tickets",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage flights and route details.",
                style: TextStyle(fontSize: 14, color: Color(0xFF697386)),
              ),
              const SizedBox(height: 24),

              // Flight List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3F51B5),
                      ),
                    );
                  }

                  if (controller.flights.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF9A825,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.flight_rounded,
                              size: 64,
                              color: Color(0xFFF9A825),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No flights available",
                            style: TextStyle(color: Color(0xFF697386)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.flights.length,
                    itemBuilder: (context, index) {
                      final flight = controller.flights[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF0F1F4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.flight_takeoff_rounded,
                                color: Color(0xFFF9A825),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flight['airline'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1A1F36),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${flight['from']} → ${flight['to']}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF697386),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "From ৳${flight['price']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF3F51B5),
                                  ),
                                ),
                                Text(
                                  "${flight['availableSeats'] ?? 0} seats total",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF697386),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      onPressed: () => _showFlightForm(
                                        context,
                                        controller,
                                        flight: flight,
                                      ),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF697386),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: 'Delete Flight',
                                          middleText:
                                              'Remove this flight entry?',
                                          textConfirm: 'Delete',
                                          textCancel: 'Cancel',
                                          confirmTextColor: Colors.white,
                                          buttonColor: const Color(0xFFE53935),
                                          onConfirm: () {
                                            controller.deleteFlight(
                                              flight['id'],
                                            );
                                            Get.back();
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFE53935),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFlightForm(
    BuildContext context,
    AdminManagementViewModel controller, {
    dynamic flight,
  }) {
    final isEdit = flight != null;
    final airlineController = TextEditingController(
      text: isEdit ? (flight['airline'] ?? '') : '',
    );
    final fromController = TextEditingController(
      text: isEdit ? (flight['from'] ?? '') : '',
    );
    final toController = TextEditingController(
      text: isEdit ? (flight['to'] ?? '') : '',
    );
    final economySeats = TextEditingController();
    final economyPrice = TextEditingController(text: isEdit ? '' : '500');
    final premiumSeats = TextEditingController();
    final premiumPrice = TextEditingController(text: isEdit ? '' : '900');
    final businessSeats = TextEditingController();
    final businessPrice = TextEditingController(text: isEdit ? '' : '1500');
    final firstSeats = TextEditingController();
    final firstPrice = TextEditingController(text: isEdit ? '' : '2500');
    bool isPopular = isEdit ? (flight['isPopular'] ?? false) : false;

    void loadSeatClass(
      String name,
      TextEditingController seats,
      TextEditingController price,
      List<dynamic> classes,
    ) {
      for (final sc in classes) {
        if ((sc['className'] ?? '').toString() == name) {
          seats.text = sc['availableSeats']?.toString() ?? '';
          price.text = sc['price']?.toString() ?? '';
          break;
        }
      }
    }

    if (isEdit) {
      final classes = flight['seatClasses'] ?? flight['SeatClasses'];
      if (classes is List && classes.isNotEmpty) {
        loadSeatClass('Economy', economySeats, economyPrice, classes);
        loadSeatClass('Premium Economy', premiumSeats, premiumPrice, classes);
        loadSeatClass('Business', businessSeats, businessPrice, classes);
        if (businessSeats.text.isEmpty && businessPrice.text.isEmpty) {
          loadSeatClass(
            'Business Class',
            businessSeats,
            businessPrice,
            classes,
          );
        }
        loadSeatClass('First Class', firstSeats, firstPrice, classes);
      } else {
        economySeats.text = flight['availableSeats']?.toString() ?? '';
        economyPrice.text = flight['price']?.toString() ?? '';
      }
    }

    DateTime selectedDate = isEdit && flight['departureTime'] != null
        ? DateTime.parse(flight['departureTime'])
        : DateTime.now();
    TimeOfDay selectedDepTime = isEdit && flight['departureTime'] != null
        ? TimeOfDay.fromDateTime(DateTime.parse(flight['departureTime']))
        : const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay selectedArrTime = isEdit && flight['arrivalTime'] != null
        ? TimeOfDay.fromDateTime(DateTime.parse(flight['arrivalTime']))
        : const TimeOfDay(hour: 11, minute: 30);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              int calcTotalSeats() {
                var sum = 0;
                for (final c in [
                  economySeats,
                  premiumSeats,
                  businessSeats,
                  firstSeats,
                ]) {
                  sum += int.tryParse(c.text.trim()) ?? 0;
                }
                return sum;
              }

              double? calcMinPrice() {
                double? min;
                for (final c in [
                  economyPrice,
                  premiumPrice,
                  businessPrice,
                  firstPrice,
                ]) {
                  final p = double.tryParse(c.text.trim());
                  if (p != null && p > 0) {
                    final currentMin = min;
                    min = currentMin == null
                        ? p
                        : (p < currentMin ? p : currentMin);
                  }
                }
                return min;
              }

              void refresh() => setModalState(() {});

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F5FC),
                          foregroundColor: const Color(0xFF1A1F36),
                          fixedSize: const Size(42, 42),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Edit Flight' : 'Add New Flight',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1F36),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Route, schedule, seats, and class pricing',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF697386),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildField(
                    airlineController,
                    'Airline Name',
                    Icons.airplanemode_active_rounded,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          fromController,
                          'From',
                          Icons.location_on_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          toController,
                          'To',
                          Icons.location_on_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Seat Classes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Default prices are ready. Enter seats for each class.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF697386)),
                  ),
                  const SizedBox(height: 8),
                  _buildSeatRow(
                    'Economy',
                    economySeats,
                    economyPrice,
                    onChanged: refresh,
                  ),
                  _buildSeatRow(
                    'Premium Economy',
                    premiumSeats,
                    premiumPrice,
                    onChanged: refresh,
                  ),
                  _buildSeatRow(
                    'Business',
                    businessSeats,
                    businessPrice,
                    onChanged: refresh,
                  ),
                  _buildSeatRow(
                    'First Class',
                    firstSeats,
                    firstPrice,
                    onChanged: refresh,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F51B5).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total available seats: ${calcTotalSeats()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calcMinPrice() != null
                              ? 'Display price (lowest): ৳${calcMinPrice()!.toStringAsFixed(2)}'
                              : 'Display price: enter class prices above',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF697386),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date and Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 5),
                              ),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 20,
                                  color: Color(0xFF3F51B5),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Date",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedDepTime,
                            );
                            if (picked != null) {
                              setModalState(() => selectedDepTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 20,
                                  color: Color(0xFF3F51B5),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Dep. Time",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedDepTime.format(context),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedArrTime,
                            );
                            if (picked != null) {
                              setModalState(() => selectedArrTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 20,
                                  color: Color(0xFFF2994A),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Arr. Time",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedArrTime.format(context),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      "Trending Airline",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    subtitle: const Text("Mark as popular and trending flight"),
                    value: isPopular,
                    onChanged: (val) => setModalState(() => isPopular = val),
                    activeThumbColor: const Color(0xFFF9A825),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      final depDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedDepTime.hour,
                        selectedDepTime.minute,
                      );
                      var arrDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedArrTime.hour,
                        selectedArrTime.minute,
                      );
                      if (arrDateTime.isBefore(depDateTime)) {
                        arrDateTime = arrDateTime.add(const Duration(days: 1));
                      }

                      List<Map<String, dynamic>> seatClasses = [];
                      bool hasInvalidSeatClass = false;
                      void addClass(
                        String name,
                        TextEditingController seats,
                        TextEditingController price,
                      ) {
                        final hasSeatInput = seats.text.trim().isNotEmpty;
                        final hasPriceInput = price.text.trim().isNotEmpty;
                        final s = int.tryParse(seats.text) ?? 0;
                        final p = double.tryParse(price.text) ?? 0;
                        if ((hasSeatInput && s <= 0) ||
                            (hasPriceInput && p <= 0) ||
                            (s > 0 && p <= 0)) {
                          hasInvalidSeatClass = true;
                        }
                        if (s > 0 && p > 0) {
                          seatClasses.add({
                            'className': name,
                            'availableSeats': s,
                            'price': p,
                          });
                        }
                      }

                      addClass('Economy', economySeats, economyPrice);
                      addClass('Premium Economy', premiumSeats, premiumPrice);
                      addClass('Business', businessSeats, businessPrice);
                      addClass('First Class', firstSeats, firstPrice);

                      if (hasInvalidSeatClass) {
                        Get.snackbar(
                          'Invalid Input',
                          'Seats and price must be greater than zero.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withValues(alpha: 0.85),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      if (seatClasses.isEmpty) {
                        Get.snackbar(
                          'Validation',
                          'Add at least one seat class with seats and price.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withValues(alpha: 0.85),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final minPrice = calcMinPrice() ?? 0;
                      final totalSeats = calcTotalSeats();

                      final data = {
                        'airline': airlineController.text,
                        'from': fromController.text,
                        'to': toController.text,
                        'price': minPrice,
                        'availableSeats': totalSeats,
                        'seatClasses': seatClasses,
                        'departureTime': depDateTime.toIso8601String(),
                        'arrivalTime': arrDateTime.toIso8601String(),
                        'isPopular': isPopular,
                      };
                      if (isEdit) {
                        controller.updateFlight(flight['id'], data);
                      } else {
                        controller.addFlight(data);
                      }
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(isEdit ? 'Update Flight' : 'Save Flight'),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNum = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildSeatRow(
    String label,
    TextEditingController seats,
    TextEditingController price, {
    VoidCallback? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE7EAF5)),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1A1F36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: TextField(
              controller: seats,
              keyboardType: TextInputType.number,
              inputFormatters: [PositiveIntegerInputFormatter()],
              onChanged: (_) => onChanged?.call(),
              decoration: InputDecoration(
                labelText: 'Seats',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: TextField(
              controller: price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [PositiveDecimalInputFormatter()],
              onChanged: (_) => onChanged?.call(),
              decoration: InputDecoration(
                labelText: 'Price (৳)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
