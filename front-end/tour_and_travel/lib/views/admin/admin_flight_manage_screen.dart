import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_management_controller.dart';
import '../../core/constant/app_colors.dart';

class AdminFlightManageScreen extends StatelessWidget {
  const AdminFlightManageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminManagementController());

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1F36), size: 20),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF697386),
                ),
              ),
              const SizedBox(height: 24),

              // Flight List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)));
                  }
                  
                  if (controller.flights.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9A825).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flight_rounded, size: 64, color: Color(0xFFF9A825)),
                          ),
                          const SizedBox(height: 16),
                          const Text("No flights available", style: TextStyle(color: Color(0xFF697386))),
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
                              color: Colors.black.withOpacity(0.02),
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
                              child: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFFF9A825), size: 28),
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
                                  "\$${flight['price']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF3F51B5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      onPressed: () => _showFlightForm(context, controller, flight: flight),
                                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF697386), size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: 'Delete Flight',
                                          middleText: 'Remove this flight entry?',
                                          textConfirm: 'Delete',
                                          textCancel: 'Cancel',
                                          confirmTextColor: Colors.white,
                                          buttonColor: const Color(0xFFE53935),
                                          onConfirm: () {
                                            controller.deleteFlight(flight['id']);
                                            Get.back();
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 18),
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

  void _showFlightForm(BuildContext context, AdminManagementController controller, {dynamic flight}) {
    final isEdit = flight != null;
    final airlineController = TextEditingController(text: isEdit ? (flight['airline'] ?? '') : '');
    final fromController = TextEditingController(text: isEdit ? (flight['from'] ?? '') : '');
    final toController = TextEditingController(text: isEdit ? (flight['to'] ?? '') : '');
    final priceController = TextEditingController(text: isEdit ? (flight['price'].toString()) : '');
    final seatController = TextEditingController(text: isEdit ? (flight['availableSeats'].toString()) : '');
    bool isPopular = isEdit ? (flight['isPopular'] ?? false) : false;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                isEdit ? 'Edit Flight' : 'Add New Flight',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
              ),
              const SizedBox(height: 24),
              _buildField(airlineController, 'Airline Name', Icons.airplanemode_active_rounded),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildField(fromController, 'From', Icons.location_on_rounded)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildField(toController, 'To', Icons.location_on_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(priceController, 'Price (\$)', Icons.attach_money_rounded, isNum: true),
              const SizedBox(height: 16),
              _buildField(seatController, 'Seats Available', Icons.event_seat_rounded, isNum: true),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return SwitchListTile(
                    title: const Text("Trending Airline", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
                    subtitle: const Text("Mark as popular and trending flight"),
                    value: isPopular,
                    onChanged: (val) => setModalState(() => isPopular = val),
                    activeColor: const Color(0xFFF9A825),
                    contentPadding: EdgeInsets.zero,
                  );
                }
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final data = {
                    'airline': airlineController.text,
                    'from': fromController.text,
                    'to': toController.text,
                    'price': double.parse(priceController.text),
                    'availableSeats': int.parse(seatController.text),
                    'departureTime': DateTime.now().toIso8601String(), // Mocked for now
                    'arrivalTime': DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
                    'isPopular': isPopular,
                  };
                  if (isEdit) {
                    controller.updateFlight(flight['id'], data);
                  } else {
                    controller.addFlight(data);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(isEdit ? 'Update Flight' : 'Save Flight'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNum = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
