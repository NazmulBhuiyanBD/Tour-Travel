import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_management_controller.dart';

class AdminPopularAirlinesScreen extends StatelessWidget {
  const AdminPopularAirlinesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminManagementController>();
    controller.fetchFlights();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
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
                    "Popular Airlines",
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
                "Manage trending and popular airline highlights.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF697386),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.flights.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFF9A825)));
                  }
                  
                  if (controller.flights.isEmpty) {
                    return const Center(child: Text("No flights available", style: TextStyle(color: Color(0xFF697386))));
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.flights.length,
                    itemBuilder: (context, index) {
                      final flight = controller.flights[index];
                      bool isPopular = flight['isPopular'] ?? false;
                      
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
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFFF9A825), size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flight['airline'] ?? 'Airline',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1A1F36),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${flight['from']} → ${flight['to']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF697386),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isPopular,
                              onChanged: (val) => controller.togglePopularFlight(flight['id']),
                              activeColor: const Color(0xFFF9A825),
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
}
