import 'package:get/get.dart';
import '../data/repositories/hotel_repository.dart';

class HotelViewModel extends GetxController {
  final HotelRepository _hotelRepository = HotelRepository();

  var isLoading = false.obs;
  var hotelList = [].obs;
  var searchResults = [].obs;
  var _originalHotelList = [];
  var _originalSearchResults = [];
  var searchLocation = ''.obs;
  var selectedSortType = 'default'.obs;

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
      _originalHotelList = List.from(response);
      if (searchLocation.value.isEmpty) {
        searchResults.value = response;
        _originalSearchResults = List.from(response);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  void searchHotels(String query) {
    searchLocation.value = query;
    if (query.isEmpty) {
      searchResults.value = hotelList;
      _originalSearchResults = List.from(hotelList);
    } else {
      final results = hotelList
          .where((hotel) =>
              (hotel['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
              (hotel['location'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
      searchResults.value = results;
      _originalSearchResults = List.from(results);
    }
  }

  void sortHotels(String type) {
    selectedSortType.value = type;
    if (type == 'low') {
      searchResults.sort((a, b) => (a['pricePerNight'] ?? a['price'] ?? 0).compareTo(b['pricePerNight'] ?? b['price'] ?? 0));
      hotelList.sort((a, b) => (a['pricePerNight'] ?? a['price'] ?? 0).compareTo(b['pricePerNight'] ?? b['price'] ?? 0));
    } else if (type == 'high') {
      searchResults.sort((a, b) => (b['pricePerNight'] ?? b['price'] ?? 0).compareTo(a['pricePerNight'] ?? a['price'] ?? 0));
      hotelList.sort((a, b) => (b['pricePerNight'] ?? b['price'] ?? 0).compareTo(a['pricePerNight'] ?? a['price'] ?? 0));
    } else {
      hotelList.value = List.from(_originalHotelList);
      searchResults.value = List.from(_originalSearchResults);
    }
    searchResults.refresh();
    hotelList.refresh();
  }

  String _parseErrorMessage(dynamic error) {
    final raw = error.toString();
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(raw);
    if (match != null) return match.group(1)!;
    return raw.replaceFirst('Invalid Request: ', '');
  }

  Future<bool> bookHotel(
    int hotelId,
    String checkInDate,
    String checkOutDate,
    String transactionId,
    String paymentMethod, {
    int roomCount = 1,
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {
        'hotelId': hotelId,
        'roomId': 0,
        'roomCount': roomCount.clamp(1, 4),
        'checkIn': checkInDate,
        'checkOut': checkOutDate,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
      };

      await _hotelRepository.bookHotel(data);


      Get.snackbar("Success", "Hotel booked successfully!");
      return true;
    } catch (e) {
      Get.snackbar("Booking Failed", _parseErrorMessage(e));
      return false;
    } finally {
      isLoading(false);
    }
  }
}
