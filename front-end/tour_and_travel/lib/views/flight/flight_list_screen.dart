import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/flight_controller.dart';
import '../../core/constant/app_colors.dart';
import 'flight_booking_screen.dart';
import 'flight_search_screen.dart';

class FlightListScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final FlightController _flightController = Get.put(FlightController());

  FlightListScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // Hero Header
          _buildHeroHeader(context),

          // Filter Bar
          _buildFilterBar(),

          // Flight List
          Expanded(
            child: Obx(() {
              if (_flightController.isLoading.value && _flightController.flightList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }

              final flights = _flightController.fromCity.value.isEmpty
                  ? _flightController.flightList
                  : _flightController.searchResults;

              if (flights.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flight_takeoff, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        "No flights available.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.to(() => const FlightSearchScreen()),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                        child: const Text("Search Flights", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  var flight = flights[index];
                  return _buildFlightCard(flight);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://www.savethestudent.org/uploads/flights.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  AppColors.scaffoldBg.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  IconButton(
                    onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  ),
                  Center(
                    child: Obx(() {
                      final from = _flightController.fromCity.value;
                      final to = _flightController.toCity.value;
                      return Text(
                        (from.isEmpty || to.isEmpty) ? 'Flights' : '$from to $to',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => Get.to(() => const FlightSearchScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final flights = _flightController.fromCity.value.isEmpty
                ? _flightController.flightList
                : _flightController.searchResults;
            return Text(
              "Showing ${flights.length} Flights",
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            );
          }),
          Row(
            children: [
              const Text("Sort by:", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(width: 8),
              Obx(() {
                String currentSort = _flightController.selectedSortType.value;
                String label = "Default";
                if (currentSort == 'low') label = "Low to High";
                if (currentSort == 'high') label = "High to Low";
                
                return PopupMenuButton<String>(
                  onSelected: (String value) => _flightController.sortFlights(value),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'default',
                      child: Text('Default'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'low',
                      child: Text('Price: Low to High'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'high',
                      child: Text('Price: High to Low'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(dynamic flight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => FlightBookingScreen(
              flightId: flight['id'] ?? 0,
              airline: flight['airline'] ?? 'Airline',
              price: (flight['price'] ?? 0).toDouble(),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.airplanemode_active, color: AppColors.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          flight['airline'] ?? 'Airline',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Text(
                      '\$${flight['price'] ?? '0'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.cardGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeLocation(
                      flight['departureTime']?.substring(11, 16) ?? '09:00',
                      flight['from'] ?? 'ISB',
                      CrossAxisAlignment.start,
                      AppColors.primaryBlue,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            const Text("Direct", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(Icons.flight_takeoff, size: 18, color: AppColors.primaryBlue),
                                ),
                                Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildTimeLocation(
                      flight['arrivalTime']?.substring(11, 16) ?? '11:35',
                      flight['to'] ?? 'DXB',
                      CrossAxisAlignment.end,
                      const Color(0xFFF2994A),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available: ${flight['availableSeats'] ?? 0} seats',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    const Text(
                      "Book Now",
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeLocation(String time, String code, CrossAxisAlignment alignment, Color color) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          time,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
