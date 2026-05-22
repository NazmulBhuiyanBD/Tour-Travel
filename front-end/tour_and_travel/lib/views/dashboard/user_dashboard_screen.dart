import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/booking_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/notification_view_model.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/api_constants.dart';
import '../../routes/app_routes.dart';
import '../common_widgets/app_drawer.dart' as tour_and_travel_support;
import '../profile/edit_profile_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  final BookingViewModel controller = Get.put(BookingViewModel());
  final AuthViewModel authViewModel = Get.find<AuthViewModel>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const tour_and_travel_support.AppDrawer(),
      backgroundColor: AppColors.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchBookingHistory();
          await authViewModel.fetchUserProfile();
        },
        child: Column(
          children: [
            // Curved Blue Header with User Info
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildProfileInfo(context),
                    const SizedBox(height: 20),
                    const Text(
                      "Booking Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Summary Cards
                    _buildSummaryCard(
                      icon: Icons.hotel,
                      iconBg: Colors.white.withOpacity(0.3),
                      title: "Hotel Bookings",
                      count: controller.hotelCount.value.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                      ),
                      onTap: () => Get.toNamed(Routes.MY_HOTEL_BOOKINGS),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      icon: Icons.flight,
                      iconBg: Colors.white.withOpacity(0.3),
                      title: "Flight Bookings",
                      count: controller.flightCount.value.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9A825), Color(0xFFFFCA28)],
                      ),
                      onTap: () => Get.toNamed(Routes.MY_FLIGHT_BOOKINGS),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(
                      icon: Icons.tour,
                      iconBg: Colors.white.withOpacity(0.3),
                      title: "Tour Bookings",
                      count: controller.tourCount.value.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                      ),
                      onTap: () => Get.toNamed(Routes.MY_TOUR_BOOKINGS),
                    ),

                    const SizedBox(height: 30),
                    
                    // Welcome Message or Tip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            "Ready for your next adventure?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Explore our latest flight and hotel deals specially curated for you.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final NotificationViewModel notifController = Get.put(NotificationViewModel());
                    final int count = notifController.unreadCount.value;
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        ),
                        if (count > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.home_outlined, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final user = authViewModel.user.value;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                        ? NetworkImage("${ApiConstants.mediaBaseUrl}${user.profilePicture}")
                        : null,
                    child: user.profilePicture == null || user.profilePicture!.isEmpty
                        ? const Icon(Icons.person, size: 45, color: AppColors.primaryBlue)
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.name ?? "User",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            user.email ?? "noemail@example.com",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String count,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Bookings",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Obx(() {
      final user = authViewModel.user.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Profile Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.to(() => const EditProfileScreen()),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.zero,
                  ),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildProfileRow(Icons.email, "Email", user.email ?? "Not provided"),
            _buildProfileRow(Icons.phone, "Phone", user.phone ?? "Not provided"),
            _buildProfileRow(Icons.person, "Gender", user.gender ?? "Not provided"),
            _buildProfileRow(Icons.cake, "Date of Birth", _formatDate(user.dateOfBirth)),
            _buildProfileRow(Icons.location_on, "Address", user.address ?? "Not provided"),
          ],
        ),
      );
    });
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "Not provided";
    try {
      final date = DateTime.parse(isoDate);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoDate;
    }
  }
}

