import 'package:get/get.dart';
import '../data/repositories/review_repository.dart';

class ReviewViewModel extends GetxController {
  final ReviewRepository _reviewRepository = ReviewRepository();

  var isLoading = false.obs;
  var reviews = <dynamic>[].obs;
  var userReviews = <dynamic>[].obs;
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;

  Future<void> fetchUserReviews() async {
    try {
      isLoading(true);
      final response = await _reviewRepository.getUserReviews();
      userReviews.value = response['reviews'] ?? [];
    } catch (e) {
      userReviews.value = [];
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchReviews(String itemType, int itemId) async {
    try {
      isLoading(true);
      final response = await _reviewRepository.getReviews(itemType, itemId);
      reviews.value = response['reviews'] ?? [];
      averageRating.value = (response['averageRating'] ?? 0).toDouble();
      totalReviews.value = response['totalReviews'] ?? 0;
    } catch (e) {
      // Silently handle — reviews are optional
      reviews.value = [];
      averageRating.value = 0.0;
      totalReviews.value = 0;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> submitReview(String itemType, int itemId, int rating, String comment) async {
    try {
      isLoading(true);
      await _reviewRepository.addReview({
        'itemType': itemType,
        'itemId': itemId,
        'rating': rating,
        'comment': comment,
      });
      // Refresh reviews after submitting
      await fetchReviews(itemType, itemId);
      Get.snackbar("Success", "Review submitted successfully!",
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      String msg = e.toString();
      if (msg.contains("already reviewed")) {
        Get.snackbar("Info", "You have already reviewed this item.",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to submit review",
            snackPosition: SnackPosition.BOTTOM);
      }
      return false;
    } finally {
      isLoading(false);
    }
  }
}
