import 'package:get/get.dart';
import '../data/repositories/booking_repository.dart';

class BookingController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();
  
  var isLoading = false.obs;
  var bookingHistory = <dynamic>[].obs;
  
  // Stats
  var hotelCount = 0.obs;
  var flightCount = 0.obs;
  var tourCount = 0.obs;
  var recentFlights = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookingHistory();
  }

  Future<void> fetchBookingHistory() async {
    try {
      isLoading(true);
      final response = await _bookingRepository.getBookingHistory();
      
      if (response != null && response is List) {
        bookingHistory.value = response;
        
        // Calculate Stats
        hotelCount.value = response.where((item) => item['type'] == 'Hotel').length;
        flightCount.value = response.where((item) => item['type'] == 'Flight').length;
        tourCount.value = response.where((item) => item['type'] == 'Tour').length;
        
        // Filter Recent Flights (Top 5)
        recentFlights.value = response
            .where((item) => item['type'] == 'Flight')
            .take(5)
            .toList();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
