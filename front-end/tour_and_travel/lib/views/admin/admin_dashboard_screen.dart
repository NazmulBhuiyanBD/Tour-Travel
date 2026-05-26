import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../view_models/auth_view_model.dart';
import '../../view_models/admin_management_view_model.dart';
import '../../routes/app_routes.dart';
import '../support/admin_ticket_list_view.dart' as tour_and_travel_support;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final AuthViewModel authViewModel = Get.find<AuthViewModel>();
    final AdminManagementViewModel adminController = Get.put(
      AdminManagementViewModel(),
    );

    // Refresh data on build to ensure it's dynamic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminController.fetchDashboardData();
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F7FC), // Softer premium background
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3F51B5).withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3F51B5).withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar wrapped in glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                              ),
                              child: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'logout') {
                                    authViewModel.logout();
                                  } else if (value == 'change_password') {
                                    _showChangePasswordDialog(
                                      context,
                                      authViewModel,
                                    );
                                  }
                                },
                                offset: const Offset(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'change_password',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.lock_reset,
                                          size: 20,
                                          color: Color(0xFF4F566B),
                                        ),
                                        SizedBox(width: 12),
                                        Text("Change Password"),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          size: 20,
                                          color: Color(0xFFE53935),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Logout",
                                          style: TextStyle(
                                            color: Color(0xFFE53935),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        'https://www.shutterstock.com/image-vector/simple-outline-user-configuration-setting-600nw-2636195015.jpg',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authViewModel.user.value.name ??
                                              "Admin",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1F36),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                color: Color(0xFF3F51B5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Console Header
                  const Text(
                    "Admin Console",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Welcome back. Here's what's happening today.",
                    style: TextStyle(fontSize: 14, color: Color(0xFF697386)),
                  ),

                  const SizedBox(height: 28),

                  // Stats Row
                  Obx(() {
                    final stats = adminController.dashboardData;
                    final revenue = stats['totalRevenue'] ?? 0;
                    final bookings = stats['totalBookings'] ?? 0;

                    return Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Get.toNamed(Routes.ADMIN_REVENUE_REPORT),
                            borderRadius: BorderRadius.circular(16),
                            child: _StatCard(
                              title: "Total Revenue",
                              value: "৳${revenue.toStringAsFixed(2)}",
                              trend: "+18%",
                              isPositive: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: "Total Bookings",
                            value: bookings.toString(),
                            trend: "+12k",
                            isPositive: true,
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  const Text(
                    "QUICK ACTIONS",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F566B),
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Grid
                  Obx(() {
                    final stats = adminController.dashboardData;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                      children: [
                        _ActionCard(
                          title: "Manage Users",
                          subtitle: "${stats['users'] ?? 0} active",
                          icon: Icons.people_alt_rounded,
                          iconColor: const Color(0xFF3F51B5),
                          onTap: () => Get.toNamed(Routes.ADMIN_USER_MANAGE),
                        ),
                        _ActionCard(
                          title: "Air Tickets",
                          subtitle: "${stats['flights'] ?? 0} flights",
                          icon: Icons.flight_rounded,
                          iconColor: const Color(0xFFF9A825),
                          onTap: () => Get.toNamed(Routes.ADMIN_FLIGHT_MANAGE),
                        ),
                        _ActionCard(
                          title: "Hotels",
                          subtitle: "${stats['hotels'] ?? 0} global stays",
                          icon: Icons.hotel_rounded,
                          iconColor: const Color(0xFF43A047),
                          onTap: () => Get.toNamed(Routes.ADMIN_HOTEL_MANAGE),
                        ),
                        _ActionCard(
                          title: "Tours",
                          subtitle: "${stats['tours'] ?? 0} experiences",
                          icon: Icons.flag_rounded,
                          iconColor: const Color(0xFFE53935),
                          onTap: () => Get.toNamed(Routes.ADMIN_TOUR_MANAGE),
                        ),
                        _ActionCard(
                          title: "Bookings",
                          subtitle: "${stats['totalBookings'] ?? 0} total",
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFF607D8B),
                          onTap: () => Get.toNamed(Routes.ADMIN_BOOKINGS),
                        ),
                        _ActionCard(
                          title: "Refund Requests",
                          subtitle: "${stats['pendingRefunds'] ?? 0} pending",
                          icon: Icons.currency_exchange_rounded,
                          iconColor: const Color(0xFFD81B60),
                          onTap: () => Get.toNamed(Routes.ADMIN_REFUND_MANAGE),
                        ),
                        _ActionCard(
                          title: "Support Tickets",
                          subtitle: "Manage support",
                          icon: Icons.chat_bubble_rounded,
                          iconColor: const Color(0xFF00ACC1),
                          onTap: () => Get.to(
                            () =>
                                const tour_and_travel_support.AdminTicketListView(),
                          ),
                        ),
                        _ActionCard(
                          title: "Top Destinations",
                          subtitle: "Manage highlights",
                          icon: Icons.map_rounded,
                          iconColor: const Color(0xFF3F51B5),
                          onTap: () =>
                              Get.toNamed(Routes.ADMIN_TOP_DESTINATIONS),
                        ),
                        _ActionCard(
                          title: "Popular Airlines",
                          subtitle: "Trending carriers",
                          icon: Icons.trending_up_rounded,
                          iconColor: const Color(0xFFF9A825),
                          onTap: () =>
                              Get.toNamed(Routes.ADMIN_POPULAR_AIRLINES),
                        ),
                        _ActionCard(
                          title: "Featured Hotels",
                          subtitle: "Top selections",
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFF43A047),
                          onTap: () =>
                              Get.toNamed(Routes.ADMIN_FEATURED_HOTELS),
                        ),

                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showChangePasswordDialog(
  BuildContext context,
  AuthViewModel authViewModel,
) {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Change Password",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Old Password",
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "New Password",
              prefixIcon: Icon(Icons.password),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Confirm New Password",
              prefixIcon: Icon(Icons.check_circle_outline),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (newPasswordController.text != confirmPasswordController.text) {
              Get.snackbar(
                "Error",
                "Passwords do not match",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }
            authViewModel.changePassword(
              authViewModel.user.value.email!,
              oldPasswordController.text,
              newPasswordController.text,
            );
          },
          child: const Text("Update", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF697386),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F36),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? const Color(0xFF43A047) : Colors.red)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? const Color(0xFF43A047) : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.15),
                      iconColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F36),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF697386)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
