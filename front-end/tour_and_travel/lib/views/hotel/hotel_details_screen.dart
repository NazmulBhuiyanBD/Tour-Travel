import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/api_constants.dart';
import '../../core/constant/app_colors.dart';
import '../../models/hotel_model.dart';
import 'hotel_booking_screen.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> hotelData;
  const HotelDetailsScreen({super.key, required this.hotelData});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  static const int _maxNights = 7;

  late HotelModel hotel;
  int _currentImageIndex = 0;
  int _nights = 1;

  @override
  void initState() {
    super.initState();
    hotel = HotelModel.fromJson(widget.hotelData);
  }

  @override
  Widget build(BuildContext context) {
    final images = hotel.galleryList;
    final double perNight = hotel.pricePerNight ?? 850;
    final double totalPrice = perNight * _nights;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Carousel
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
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
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index].startsWith('http')
                            ? images[index]
                            : "${ApiConstants.mediaBaseUrl}${images[index]}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.hotel,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
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
                                alpha: _currentImageIndex == entry.key
                                    ? 0.9
                                    : 0.4,
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name ?? "Premium Hotel",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.accentGold,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (hotel.rating ?? 0) > 0
                                ? hotel.rating!.toStringAsFixed(1)
                                : "New",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hotel.location ?? "City Center",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Description
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hotel.description ??
                        "Located in the heart of the city, this hotel offers luxurious rooms, fine dining, and exceptional service. Perfect for both business and leisure travelers.",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (hotel.amenitiesList.isNotEmpty) ...[
                    const Text(
                      "Amenities",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 20,
                      runSpacing: 15,
                      children: hotel.amenitiesList.map((amenity) {
                        return _buildAmenity(
                          _getIconForAmenity(amenity),
                          amenity,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Stay Duration
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Stay Duration",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Maximum $_maxNights nights",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _nights > 1
                                  ? () => setState(() => _nights--)
                                  : null,
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            Text(
                              "$_nights Night${_nights > 1 ? 's' : ''}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _nights < _maxNights
                                  ? () => setState(() => _nights++)
                                  : null,
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: _nights < _maxNights
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if ((hotel.availableRooms ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.meeting_room,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${hotel.availableRooms} total rooms • ${hotel.roomSummary}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(perNight, totalPrice),
    );
  }

  Widget _buildAmenity(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  IconData _getIconForAmenity(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('pool')) return Icons.pool;
    if (lower.contains('gym') || lower.contains('fitness')) {
      return Icons.fitness_center;
    }
    if (lower.contains('restaurant') ||
        lower.contains('food') ||
        lower.contains('dining')) {
      return Icons.restaurant;
    }
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('air condition') || lower.contains('ac')) {
      return Icons.ac_unit;
    }
    if (lower.contains('bar')) return Icons.local_bar;
    if (lower.contains('spa') || lower.contains('massage')) return Icons.spa;
    if (lower.contains('pet')) return Icons.pets;
    if (lower.contains('room service')) return Icons.room_service;
    if (lower.contains('laundry')) return Icons.local_laundry_service;
    if (lower.contains('breakfast')) return Icons.breakfast_dining;
    return Icons.check_circle_outline;
  }

  Widget _buildBottomBar(double perNight, double total) {
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
                Text(
                  "৳$perNight / Night",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Total: ৳$total",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (hotel.availableRooms ?? 0) > 0
                  ? () => Get.to(
                      () => HotelBookingScreen(
                        hotelId: hotel.id ?? 0,
                        hotelName: hotel.name ?? "Hotel",
                        price: perNight,
                        availableRooms: hotel.availableRooms ?? 10,
                        initialNights: _nights,
                      ),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Book Now",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
