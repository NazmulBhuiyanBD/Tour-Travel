import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constant/app_colors.dart';
import '../../data/services/storage_service.dart';
import '../dashboard/user_dashboard_screen.dart';
import '../dashboard/booking_history_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../support/user_ticket_list_view.dart' as tour_and_travel_support;

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final user = StorageService.to.getUser();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Obx(() {
          final user = authController.user.value;
          return Column(
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 28, color: AppColors.textSecondary),
                  ),
                ),
              ),

              // User Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Avatar
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    // Name, Phone, Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            user.email ?? 'No Email',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                              SizedBox(width: 2),
                              Text(
                                'Travel Explorer',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // Menu Items
            _DrawerMenuItem(
              icon: Icons.dashboard_rounded,
              iconColor: Colors.red,
              title: 'Dashboard',
              onTap: () {
                Navigator.of(context).pop();
                if (authController.user.value.role == 'Admin' || authController.user.value.role == 'SuperAdmin') {
                   // If we're already on admin dashboard, just pop
                   if (Get.currentRoute == Routes.ADMIN_DASHBOARD) return;
                   Get.offAllNamed(Routes.ADMIN_DASHBOARD);
                } else {
                  if (Get.currentRoute == Routes.USER_DASHBOARD) return;
                  Get.to(() => UserDashboardScreen());
                }
              },
            ),
            _DrawerMenuItem(
              icon: Icons.edit,
              iconColor: Colors.green,
              title: 'Edit Profile',
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => const EditProfileScreen());
              },
            ),
            _DrawerMenuItem(
              icon: Icons.lock,
              iconColor: AppColors.primaryBlue,
              title: 'Change Password',
              onTap: () {
                Navigator.of(context).pop();
                Get.snackbar('Coming Soon', 'Change Password is under development');
              },
            ),
            _DrawerMenuItem(
              icon: Icons.flight,
              iconColor: AppColors.accentOrange,
              title: 'My Flights Bookings',
              onTap: () {
                Navigator.of(context).pop();
                Get.toNamed(Routes.MY_FLIGHT_BOOKINGS);
              },
            ),
            _DrawerMenuItem(
              icon: Icons.hotel,
              iconColor: AppColors.primaryBlue,
              title: 'My Hotels Bookings',
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => BookingHistoryScreen());
              },
            ),
            _DrawerMenuItem(
              icon: Icons.tour,
              iconColor: AppColors.cardGreen,
              title: 'My Tours Bookings',
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => BookingHistoryScreen());
              },
            ),
            _DrawerMenuItem(
              icon: Icons.star,
              iconColor: AppColors.accentGold,
              title: 'My Reviews',
              onTap: () {
                Navigator.of(context).pop();
                Get.snackbar('Coming Soon', 'Reviews is under development');
              },
            ),
            _DrawerMenuItem(
              icon: Icons.help_outline,
              iconColor: Colors.purple,
              title: 'Help / Support',
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => const tour_and_travel_support.UserTicketListView());
              },
            ),
            const Spacer(),
            _DrawerMenuItem(
              icon: Icons.logout,
              iconColor: AppColors.cardGreen,
              title: 'Logout',
              onTap: () {
                Navigator.of(context).pop();
                authController.logout();
              },
            ),
              const SizedBox(height: 20),
            ],
          );
        }),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: AppColors.primaryBlue.withOpacity(0.05),
    );
  }
}
