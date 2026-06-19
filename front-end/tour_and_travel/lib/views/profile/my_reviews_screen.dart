import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/review_view_model.dart';
import '../../core/constant/api_constants.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final ReviewViewModel _reviewViewModel = Get.put(ReviewViewModel());

  @override
  void initState() {
    super.initState();
    _reviewViewModel.fetchUserReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Premium Background
      appBar: AppBar(
        title: const Text('My Reviews', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (_reviewViewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_reviewViewModel.userReviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "You haven't written any reviews yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Complete a booking to share your experience",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _reviewViewModel.userReviews.length,
          itemBuilder: (context, index) {
            final review = _reviewViewModel.userReviews[index];
            return _buildReviewCard(review);
          },
        );
      }),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final itemType = review['itemType'] ?? 'Unknown';
    final itemName = review['itemName'] ?? 'Unknown Item';
    final itemSubtitle = review['itemSubtitle'] ?? '';
    final itemImage = review['itemImage'] ?? '';
    
    Color badgeColor;
    IconData typeIcon;

    switch (itemType.toString().toLowerCase()) {
      case 'hotel':
        badgeColor = Colors.teal;
        typeIcon = Icons.hotel_rounded;
        break;
      case 'tour':
        badgeColor = Colors.orange;
        typeIcon = Icons.tour_rounded;
        break;
      case 'flight':
        badgeColor = Colors.blue;
        typeIcon = Icons.flight_rounded;
        break;
      default:
        badgeColor = Colors.grey;
        typeIcon = Icons.card_travel_rounded;
    }

    String formattedDate = '';
    if (review['createdAt'] != null) {
      try {
        DateTime date = DateTime.parse(review['createdAt']);
        formattedDate = "${date.day}/${date.month}/${date.year}";
      } catch (e) {
        formattedDate = review['createdAt'].toString().substring(0, 10);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image / Icon Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: itemImage.toString().isNotEmpty
                      ? Image.network(
                          "${ApiConstants.mediaBaseUrl}$itemImage",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: badgeColor.withOpacity(0.1),
                            child: Icon(typeIcon, color: badgeColor, size: 28),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: badgeColor.withOpacity(0.1),
                          child: Icon(typeIcon, color: badgeColor, size: 28),
                        ),
                ),
                const SizedBox(width: 14),
                // Item Details (Name, Type, Subtitle, Date)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon, size: 12, color: badgeColor),
                                const SizedBox(width: 4),
                                Text(
                                  itemType,
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (itemSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          itemSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              children: List.generate(5, (index) {
                int rating = review['rating'] ?? 0;
                return Icon(
                  index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              review['comment'] ?? '',
              style: const TextStyle(
                color: Color(0xFF4F566B),
                fontSize: 14.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
