import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/views/main_screen.dart';
import '../../core/constant/api_constants.dart';
import '../../core/constant/app_colors.dart';
import '../../view_models/dashboard_view_model.dart';
import '../../view_models/notification_view_model.dart';
import '../../routes/app_routes.dart';
import '../hotel/hotel_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final DashboardViewModel controller = Get.put(DashboardViewModel());

  DashboardScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 28),
        ),
        title: const Text(
          "NAZTRAVEL",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Obx(() {
            final NotificationViewModel notifController = Get.put(NotificationViewModel());
            final int count = notifController.unreadCount.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 28),
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
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchAll();
          if (Get.isRegistered<NotificationViewModel>()) {
            await Get.find<NotificationViewModel>().fetchNotifications();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Blue Card
              _buildWelcomeCard(),
    
              // Top Destinations
              _buildSectionTitle("Top Destinations"),
              Obx(() => _buildDestinationsList()),
    
              // Popular Airlines
              _buildSectionTitle("Popular Airlines"),
              Obx(() => _buildAirlinesList()),
    
              // Featured Hotels
              _buildSectionTitle("Featured Hotels"),
              Obx(() => _buildHotelsList()),
    
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.welcomeGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome to NAZTRAVEL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your gateway to unforgettable journeys.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _categoryBtn(Icons.flight, "Flights", Colors.white, AppColors.primaryBlue, () {
                Get.find<MainNavigationController>().changeTabIndex(1);
              }),
              const SizedBox(width: 10),
              _categoryBtn(Icons.hotel, "Hotels", AppColors.accentOrange, Colors.white, () {
                Get.find<MainNavigationController>().changeTabIndex(2);
              }),
              const SizedBox(width: 10),
              _categoryBtn(Icons.location_on, "Tours", const Color(0xFF1A237E), Colors.white, () {
                Get.find<MainNavigationController>().changeTabIndex(3);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryBtn(IconData icon, String label, Color bgColor, Color contentColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: contentColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDestinationsList() {
    if (controller.isLoadingTop.value) {
      return const SizedBox(height: 130, child: Center(child: CircularProgressIndicator()));
    }

    if (controller.topDestinations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text("No top destinations highlighted yet.", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      );
    }

    final List<Color> sectionColors = [Colors.blue, Colors.purple, Colors.teal, Colors.orange, Colors.pink];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.topDestinations.length,
        padding: const EdgeInsets.only(left: 16),
        itemBuilder: (context, i) {
          final tour = controller.topDestinations[i];
          final color = sectionColors[i % sectionColors.length];
          
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.7),
                        color,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.location_city, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    tour['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "${tour['durationDays']} Days",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAirlinesList() {
    if (controller.isLoadingAirlines.value) {
      return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
    }

    if (controller.popularAirlines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text("No popular airlines featured.", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      );
    }

    final List<Color> airlineColors = [Colors.blue, Colors.red, Colors.orange, Colors.indigo, Colors.green];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.popularAirlines.length,
        padding: const EdgeInsets.only(left: 16),
        itemBuilder: (context, i) {
          final flight = controller.popularAirlines[i];
          final color = airlineColors[i % airlineColors.length];

          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: color.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                flight['airline'] ?? 'Airline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotelsList() {
    if (controller.isLoadingHotels.value) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
    }

    if (controller.featuredHotels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Text("No featured hotels at the moment.", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: controller.featuredHotels.asMap().entries.map((entry) {
            final hotel = entry.value;
            final index = entry.key;
            return GestureDetector(
              onTap: () {
                // Ensure hotel is a map before passing to HotelDetailsScreen
                final hotelData = hotel is Map<String, dynamic> ? hotel : Map<String, dynamic>.from(hotel);
                Get.to(() => HotelDetailsScreen(hotelData: hotelData));
              },
              child: Container(
                width: 180,
                margin: EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        color: index % 2 == 0 ? Colors.indigo.shade100 : Colors.teal.shade100,
                        child: hotel['imageUrl'] != null && hotel['imageUrl'] != ""
                         ? Image.network(
                            "${ApiConstants.mediaBaseUrl}${hotel['imageUrl']}",
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Icon(
                              Icons.hotel,
                              size: 48,
                              color: index % 2 == 0 ? Colors.indigo : Colors.teal,
                            ),
                          )
                         : Icon(
                            Icons.hotel,
                            size: 48,
                            color: index % 2 == 0 ? Colors.indigo : Colors.teal,
                          ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hotel['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hotel['location'] ?? '',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            );
          }).toList(),
        ),
      ),
    );
  }
}