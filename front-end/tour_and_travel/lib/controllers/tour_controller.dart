import 'package:get/get.dart';
import '../data/repositories/tour_repository.dart';

class TourController extends GetxController {
  final TourRepository _tourRepository = TourRepository();
  
  var isLoading = false.obs;
  var tourList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTours();
  }

  Future<void> fetchTours() async {
    try {
      isLoading(true);
      final response = await _tourRepository.getAllTours();
      tourList.value = response;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<bool> bookTour(int tourId, String transactionId, String paymentMethod) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {
        'tourId': tourId,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
      };

      await _tourRepository.bookTour(data);


      Get.snackbar("Success", "Tour booked successfully!");
      return true;
    } catch (e) {
      Get.snackbar("Booking Failed", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }
}
