import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/app_colors.dart';

class FlightBookingDetailsScreen extends StatelessWidget {
  final dynamic booking;

  const FlightBookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final String status = booking['status'] ?? 'Confirmed';
    final bool isConfirmed = status.toLowerCase() == 'confirmed';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Flight Booking Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order ID
                        Text(
                          "Order ID: ${booking['id']?.toString() ?? 'off_0000AzdG1Y2vwyd7eemLxt'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Booking Date and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Booked:",
                                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking['bookingDate']?.toString().replaceAll('T', ' ').substring(0, 16) ?? "Mon, Oct 27, 2025, 10:55 AM",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isConfirmed ? const Color(0xFF27AE60) : const Color(0xFFF2994A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Airline and Price Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FB),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Emirates",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$${booking['totalPrice'] ?? '321.68'}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Text(
                                    "Total Fare",
                                    style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 20),

                        // Depart Section
                        const Text(
                          "DEPART",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Route
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "ISB",
                              style: TextStyle(
                                color: Color(0xFF2F80ED),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Row(
                                      children: List.generate(20, (index) {
                                        return Expanded(
                                          child: Container(
                                            height: 1.5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            color: index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent,
                                          ),
                                        );
                                      }),
                                    ),
                                    const Icon(Icons.flight, color: Color(0xFF2F80ED), size: 28),
                                  ],
                                ),
                              ),
                            ),
                            const Text(
                              "DXB",
                              style: TextStyle(
                                color: Color(0xFF2F80ED),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 25),

                        // Timeline
                        _buildTimelineItem(
                          title: "Fri, Oct 31, 2025, 9:00 AM",
                          subtitle: "Depart from Islamabad International Airport",
                        ),
                        _buildTimelineItem(
                          title: "Flight duration: 2h:35m",
                          subtitle: "",
                          isStep: true,
                        ),
                        _buildTimelineItem(
                          title: "Fri, Oct 31, 2025, 11:35 AM",
                          subtitle: "Arrive at Dubai International Airport, Terminal 3",
                          isLast: true,
                        ),

                        const SizedBox(height: 25),
                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 20),

                        // Flight Details Table
                        const Text(
                          "Flight Details (Depart)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow("Cabin Class", "ECONOMY"),
                        _buildDetailRow("Airline Name", "Emirates"),
                        _buildDetailRow("Flight Number", "0613"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    bool isLast = false,
    bool isStep = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isStep ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: isStep ? Colors.black87 : const Color(0xFF2F80ED),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 25),
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (isStep) const SizedBox(height: 25),
                if (isLast) const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
