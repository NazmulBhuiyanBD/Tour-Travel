import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_management_controller.dart';
import '../../core/constant/app_colors.dart';

class AdminBookingManageScreen extends StatefulWidget {
  const AdminBookingManageScreen({Key? key}) : super(key: key);

  @override
  State<AdminBookingManageScreen> createState() => _AdminBookingManageScreenState();
}

class _AdminBookingManageScreenState extends State<AdminBookingManageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.find<AdminManagementController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                        "Bookings",
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
                    "Manage and review active itineraries.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF697386),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Custom Tab Bar
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F1F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: const Color(0xFF3F51B5),
                      unselectedLabelColor: const Color(0xFF697386),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: "Hotels"),
                        Tab(text: "Flights"),
                        Tab(text: "Tours"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _BookingList(type: 'hotel', controller: controller),
                  _BookingList(type: 'flight', controller: controller),
                  _BookingList(type: 'tour', controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final String type;
  final AdminManagementController controller;

  const _BookingList({required this.type, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List bookings;
      IconData icon;
      Color tintColor;
      
      if (type == 'hotel') {
        bookings = controller.hotelBookings;
        icon = Icons.hotel_rounded;
        tintColor = const Color(0xFF43A047);
      } else if (type == 'flight') {
        bookings = controller.flightBookings;
        icon = Icons.flight_rounded;
        tintColor = const Color(0xFFF9A825);
      } else {
        bookings = controller.tourBookings;
        icon = Icons.tour_rounded;
        tintColor = const Color(0xFFE53935);
      }

      if (bookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: tintColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: tintColor),
              ),
              const SizedBox(height: 24),
              Text(
                "No ${type} bookings found",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36)),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "There are currently no active reservations in the system for this period.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF697386), fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#ID-${booking['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F51B5), fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(color: Color(0xFF43A047), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (type == 'hotel') ...[
                  _DetailRow(Icons.business_rounded, 'Hotel', booking['hotelName'] ?? 'N/A'),
                  _DetailRow(Icons.calendar_today_rounded, 'Date', '${_formatDate(booking['checkInDate'])} - ${_formatDate(booking['checkOutDate'])}'),
                ] else if (type == 'flight') ...[
                  _DetailRow(Icons.flight_rounded, 'Route', '${booking['from']} → ${booking['to']}'),
                  _DetailRow(Icons.access_time_rounded, 'Departure', _formatDate(booking['departureTime'])),
                ] else ...[
                  _DetailRow(Icons.explore_rounded, 'Tour', booking['tourTitle'] ?? 'N/A'),
                  _DetailRow(Icons.calendar_month_rounded, 'Date', _formatDate(booking['bookingDate'])),
                ],
                const Divider(height: 24, color: Color(0xFFF0F1F4)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'User ID: ${booking['userId']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF697386), fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '\$${booking['totalPrice'] ?? 0}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1F36)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _DetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF697386)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, color: Color(0xFF697386))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)))),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return 'N/A';
    }
  }
}
