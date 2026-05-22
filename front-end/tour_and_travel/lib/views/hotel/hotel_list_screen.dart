import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/hotel_view_model.dart';
import '../../core/constant/api_constants.dart';
import '../../core/constant/app_colors.dart';
import 'hotel_booking_screen.dart';
import 'hotel_details_screen.dart';
import 'hotel_search_screen.dart';
import '../../routes/app_routes.dart';

class HotelListScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final HotelViewModel _hotelViewModel = Get.put(HotelViewModel());

  HotelListScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // Hero Header
          _buildHeroHeader(context),

          // Filter + Search Buttons
          _buildFilterRow(),

          // Hotel List
          Expanded(
            child: Obx(() {
              if (_hotelViewModel.isLoading.value && _hotelViewModel.hotelList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }

              final hotels = _hotelViewModel.searchResults;

              if (hotels.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        "No hotels found.",
                        style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Showing ${hotels.length} Search Results",
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        var hotel = hotels[index];
                        return _buildHotelCard(hotel);
                      },
                    ),
                  ),
                ],
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
              image: NetworkImage('https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=800'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.scaffoldBg],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
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
                  const Center(
                    child: Text(
                      "Hotels",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort Dropdown
          Expanded(
            child: Obx(() {
              String currentSort = _hotelViewModel.selectedSortType.value;
              String label = "Default";
              if (currentSort == 'low') label = "Low to High";
              if (currentSort == 'high') label = "High to Low";

              return PopupMenuButton<String>(
                onSelected: (String value) => _hotelViewModel.sortHotels(value),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'default', child: Text('Default')),
                  const PopupMenuItem<String>(value: 'low', child: Text('Price: Low to High')),
                  const PopupMenuItem<String>(value: 'high', child: Text('Price: High to Low')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.filterOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sort, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),
          // Search Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.to(() => const HotelSearchScreen()),
              icon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 18),
              label: const Text("Search Hotel", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(dynamic hotel) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.HOTEL_DETAILS, arguments: hotel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.amber.shade50,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  hotel['imageUrl'] != null && hotel['imageUrl'].toString().isNotEmpty
                      ? "${ApiConstants.mediaBaseUrl}${hotel['imageUrl']}"
                      : 'https://images.unsplash.com/photo-1542314831-c6a4d2759fac?auto=format&fit=crop&q=80&w=600',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.hotel, color: Colors.grey, size: 40),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name
                  Text(
                    hotel['name'] ?? 'Hotel Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Stars
                  Row(
                    children: List.generate(
                      5,
                      (i) => const Icon(Icons.star, color: AppColors.starColor, size: 20),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel['location'] ?? 'Location',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${hotel['pricePerNight'] ?? hotel['price'] ?? '0'}',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: ' / night',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // View Details Button
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.HOTEL_DETAILS, arguments: hotel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
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
}
