import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/api_constants.dart';
import '../../core/constant/app_colors.dart';
import '../../models/tour_model.dart';
import 'tour_booking_screen.dart';

class TourDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> tourData;
  const TourDetailsScreen({super.key, required this.tourData});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  late TourModel tour;
  int _currentImageIndex = 0;
  @override
  void initState() {
    super.initState();
    tour = TourModel.fromJson(widget.tourData);
  }

  @override
  Widget build(BuildContext context) {
    final images = tour.galleryList;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsing App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index].startsWith('http') 
                          ? images[index] 
                          : "${ApiConstants.mediaBaseUrl}${images[index]}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.tour, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  // Image Indicators
                  if (images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: _currentImageIndex == entry.key ? 0.9 : 0.4,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          tour.title ?? "Tour Package",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (tour.startDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tour.startDate!.toLocal().toString().substring(0, 10),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),

                   // Duration and Location
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildInfoIcon(Icons.flight_takeoff, "Start: ${tour.startPoint ?? 'Dhaka'}"),
                        const SizedBox(width: 16),
                        _buildInfoIcon(Icons.flight_land, "End: ${tour.endPoint ?? 'Destination'}"),
                        const SizedBox(width: 16),
                        _buildInfoIcon(Icons.timer, "${tour.durationDays ?? 1}D / ${(tour.durationDays ?? 1) > 1 ? (tour.durationDays! - 1) : 0}N"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Description Header
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tour.description ?? "Experience the beauty of nature with our exclusive tour package. Explore exotic locations and enjoy top-notch services.",
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Itinerary Header
                  if (tour.itinerary != null && tour.itinerary!.isNotEmpty) ...[
                    const Text(
                      "Itinerary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tour.itinerary!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // What's Included
                  const Text(
                    "What's Included",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildIncludedItem(Icons.hotel, "Luxury Accommodation"),
                  _buildIncludedItem(Icons.restaurant, "All Meals Provided"),
                  _buildIncludedItem(Icons.directions_bus, "Guided Transport"),
                  _buildIncludedItem(Icons.security, "Travel Insurance"),

                  const SizedBox(height: 16),
                  if ((tour.vacancy ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${tour.vacancy} spots left • max 4 travelers per booking",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildInfoIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIncludedItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Price",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                Text(
                  "\$${tour.price ?? 1200}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 30),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.to(() => TourBookingScreen(
                  tourId: tour.id ?? 0,
                  title: tour.title ?? "Tour",
                  price: tour.price ?? 1200,
                  vacancy: tour.vacancy ?? 20,
                  startDate: tour.startDate,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
