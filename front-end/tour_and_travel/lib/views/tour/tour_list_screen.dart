import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tour_controller.dart';
import '../../core/constant/api_constants.dart';
import '../../core/constant/app_colors.dart';
import 'tour_booking_screen.dart';
import 'tour_details_screen.dart';
import '../../routes/app_routes.dart';

class TourListScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final TourController _tourController = Get.put(TourController());

  TourListScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          // Hero Header
          _buildHeroHeader(context),

          // Search and Filter Bar
          _buildSearchFilterBar(),

          // Tour List
          Expanded(
            child: Obx(() {
              if (_tourController.isLoading.value && _tourController.tourList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.cardGreen),
                );
              }

              if (_tourController.tourList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.tour, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        "No tours available yet.",
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
                      "Showing ${_tourController.tourList.length} Tours",
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: _tourController.tourList.length,
                      itemBuilder: (context, index) {
                        var tour = _tourController.tourList[index];
                        return _buildTourCard(tour, context);
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

  Widget _buildSearchFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search tours...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
              ]
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          )
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
              image: NetworkImage('https://images.unsplash.com/photo-1528181304800-259b08848526?auto=format&fit=crop&q=80&w=800'),
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
                      "Tours",
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

  Widget _buildTourCard(dynamic tour, BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TOUR_DETAILS, arguments: tour),
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
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        tour['imageUrl'] != null && tour['imageUrl'].toString().isNotEmpty
                            ? "${ApiConstants.mediaBaseUrl}${tour['imageUrl']}"
                            : 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?auto=format&fit=crop&q=80&w=600',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.tour, color: Colors.grey, size: 40),
                        ),
                      ),
                    ),
                  ),
                  // Left chips
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 14, color: AppColors.primaryBlue),
                              const SizedBox(width: 4),
                              Text('${tour['durationDays'] ?? 10} Days', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                              const SizedBox(width: 4),
                              Text(tour['location'] ?? (tour['title'] != null ? tour['title'].toString().split(' ').take(2).join(' ') : 'Destination'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right chip
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Group', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tour['title'] ?? 'Tour Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text("Starts: 1 Oct 2025", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  Row(
                    children: [
                      const Icon(Icons.event_available, size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text("Ends: 10 Sep 2025", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.nights_stay, size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text("${(tour['durationDays'] ?? 10) - 1} Nights", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
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
