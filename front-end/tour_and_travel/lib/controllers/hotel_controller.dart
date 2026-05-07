import 'package:get/get.dart';
import '../data/repositories/hotel_repository.dart';

class HotelController extends GetxController {
  final HotelRepository _hotelRepository = HotelRepository();

  var isLoading = false.obs;
  var hotelList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    try {
      isLoading(true);
      final response = await _hotelRepository.getAllHotels();
      hotelList.value = response;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<bool> bookHotel(
    int hotelId,
    String checkInDate,
    String checkOutDate,
    String transactionId,
    String paymentMethod,
  ) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {
        'hotelId': hotelId,
        'roomId': 0, // Auto-pick in backend
        'checkIn': checkInDate,
        'checkOut': checkOutDate,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
      };

      await _hotelRepository.bookHotel(data);


      Get.snackbar("Success", "Hotel booked successfully!");
      return true;
    } catch (e) {
      Get.snackbar("Booking Failed", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }
}
