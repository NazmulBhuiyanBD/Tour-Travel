import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/booking_view_model.dart';
import '../../core/constant/app_colors.dart';
import '../../routes/app_routes.dart';
import 'flight_booking_details_screen.dart';

class MyFlightBookingsScreen extends StatelessWidget {
  final BookingViewModel _bookingViewModel = Get.put(BookingViewModel());

  MyFlightBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "My Flight Bookings",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: CustomScrollView(
        slivers: [

          // Bookings List
          Obx(() {
            final flightBookings = _bookingViewModel.bookingHistory
                .where((item) => item['type'] == 'Flight')
                .toList();

            if (_bookingViewModel.isLoading.value && flightBookings.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (flightBookings.isEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Text(
                    "No flight bookings found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = flightBookings[index];
                    return _buildFlightCard(booking);
                  },
                  childCount: flightBookings.length,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? "pm" : "am";
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${weekDays[dateTime.weekday - 1]} ${months[dateTime.month - 1]} ${dateTime.day} ${dateTime.year}";
  }

  Widget _buildFlightCard(dynamic booking) {
    final String status = booking['status'] ?? 'Confirmed';
    final bool isConfirmed = status.toLowerCase() == 'confirmed';

    final String fromCity = booking['from'] ?? 'Islamabad';
    final String toCity = booking['to'] ?? 'Dubai';
    final String fromCode = fromCity.length >= 3 ? fromCity.substring(0, 3).toUpperCase() : fromCity.toUpperCase();
    final String toCode = toCity.length >= 3 ? toCity.substring(0, 3).toUpperCase() : toCity.toUpperCase();

    DateTime? departDateTime = booking['bookingDate'] != null ? DateTime.tryParse(booking['bookingDate'].toString()) : null;
    DateTime? arriveDateTime = booking['arrivalTime'] != null ? DateTime.tryParse(booking['arrivalTime'].toString()) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Booking Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Booked:",
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['bookingDate']?.toString().replaceAll('T', ' ').substring(0, 16) ?? "2025-10-27 10:55 am",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isConfirmed ? const Color(0xFF27AE60) : const Color(0xFFF2994A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Middle Row: Route (ISB -> DXB)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAirportInfo(fromCode, fromCity, const Color(0xFF2D9CDB)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: List.generate(15, (index) {
                            return Expanded(
                              child: Container(
                                height: 1.5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                color: index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent,
                              ),
                            );
                          }),
                        ),
                        const Icon(Icons.flight, color: Color(0xFF2D9CDB), size: 24),
                      ],
                    ),
                  ),
                ),
                _buildAirportInfo(toCode, toCity, const Color(0xFFF2994A)),
              ],
            ),
            const SizedBox(height: 15),

            // Bottom Row: Times
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo(_formatTime(departDateTime), _formatDate(departDateTime), const Color(0xFF2D9CDB), CrossAxisAlignment.start),
                _buildTimeInfo(_formatTime(arriveDateTime), _formatDate(arriveDateTime), const Color(0xFFF2994A), CrossAxisAlignment.end),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade100, thickness: 1.5),
            const SizedBox(height: 15),

            // Airline and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['airline'] ?? "Emirates",
                  style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${booking['totalPrice'] ?? '321.68'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
            const SizedBox(height: 20),

            // Bottom Bar: User and Details Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFFF2994A), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          booking['userName'] ?? "Sharjeel Anjum",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.FLIGHT_BOOKING_DETAILS, arguments: booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  child: const Text(
                    "Details",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportInfo(String code, String city, Color color) {
    return Column(
      crossAxisAlignment: color == const Color(0xFF2D9CDB) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          code,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          city,
          style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(String time, String date, Color color, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
