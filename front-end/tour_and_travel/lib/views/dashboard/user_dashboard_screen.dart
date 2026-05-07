import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../core/constant/app_colors.dart';
import '../../routes/app_routes.dart';
import '../common_widgets/app_drawer.dart' as tour_and_travel_support;

class UserDashboardScreen extends StatelessWidget {
  final BookingController controller = Get.put(BookingController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const tour_and_travel_support.AppDrawer(),
      backgroundColor: AppColors.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchBookingHistory(),
        child: Column(
          children: [
            // Curved Blue Header
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCard(
                      icon: Icons.hotel,
                      iconBg: Colors.white.withOpacity(0.3),
                      title: "My Recent Hotels Bookings",
                      count: controller.hotelCount.value.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      icon: Icons.flight,
                      iconBg: Colors.white.withOpacity(0.3),
                      title: "My Recent Flights Bookings",
                      count: controller.flightCount.value.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9A825), Color(0xFFFFCA28)],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      icon: Icons.tour,
                      iconBg: Colors.white.withOpacity(0.3),
                      title: "My Recent Tour Bookings",
                      count: controller.tourCount.value.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Recent Flight Bookings
                    const Text(
                      "Recent Flight Bookings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Horizontal Scrollable Flight Cards
                    _buildRecentFlightBookings(),

                    const SizedBox(height: 20),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            ),
            const Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.home, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String count,
    required LinearGradient gradient,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFlightBookings() {
    final bookings = controller.recentFlights;



    return SizedBox(
      height: 250, // Enough height for the detailed flight card
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: bookings.length > 0 ? bookings.length : 1, // Show at least one for demo if empty
        itemBuilder: (context, index) {
          // If no bookings but we are showing a demo, provide dummy data
          var booking = bookings.isNotEmpty ? bookings[index] : {
            'status': 'CONFIRMED',
            'detailTitle': 'ISB to DXB',
            'bookingDate': '2025-10-27T05:55:00',
            'totalPrice': 321.68
          };

          return Container(
            width: 320,
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Booked:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          "27 Oct 2025 05:55am", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking['status']?.toUpperCase() ?? 'CONFIRMED',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['from'] ?? 'ISB', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        const Text("Origin", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text(
                          booking['bookingDate'] != null ? booking['bookingDate'].toString().split('T')[1].substring(0, 5) : "09:00", 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
                        ),
                        Text(
                          booking['bookingDate'] != null ? booking['bookingDate'].toString().split('T')[0] : "Departure", 
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary)
                        ),
                      ],
                    ),
                    const Icon(Icons.flight, color: AppColors.primaryBlue, size: 28),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(booking['to'] ?? 'DXB', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.cardYellow)),
                        const Text("Destination", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text(
                          booking['arrivalTime'] != null ? booking['arrivalTime'].toString().split('T')[1].substring(0, 5) : "11:35", 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cardYellow)
                        ),
                        Text(
                          booking['arrivalTime'] != null ? booking['arrivalTime'].toString().split('T')[0] : "Arrival", 
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary)
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['airline'] ?? 'Airline', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.cardYellow),
                            const SizedBox(width: 4),
                            Text(booking['referenceNumber'] ?? '#REF', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("USD${booking['totalPrice'] ?? '321.68'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Text("Total Fare", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.FLIGHT_BOOKING_DETAILS, arguments: booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text("View Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
