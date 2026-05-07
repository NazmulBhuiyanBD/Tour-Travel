import 'package:get/get.dart';
import '../data/repositories/flight_repository.dart';

class FlightController extends GetxController {
  final FlightRepository _flightRepository = FlightRepository();

  var isLoading = false.obs;
  var flightList = [].obs;
  var searchResults = [].obs;
  var _originalFlightList = [];
  var _originalSearchResults = [];
  var fromCity = ''.obs;
  var toCity = ''.obs;
  var selectedSortType = 'default'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFlights();
  }

  Future<void> fetchFlights() async {
    try {
      isLoading(true);
      final response = await _flightRepository.getAllFlights();
      flightList.value = response;
      _originalFlightList = List.from(response);
      // Ensure search results are seeded with all flights if no filter set.
      if (searchResults.isEmpty) {
        searchResults.value = response;
        _originalSearchResults = List.from(response);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> searchFlights(String from, String to) async {
    try {
      isLoading(true);
      fromCity.value = from;
      toCity.value = to;
      
      final response = await _flightRepository.searchFlights(from, to);
      searchResults.value = response;
      _originalSearchResults = List.from(response);
    } catch (e) {
      Get.snackbar("Search Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<bool> bookFlight(int flightId, int seats, String transactionId, String paymentMethod) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {
        'flightId': flightId,
        'seatCount': seats,
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
      };

      await _flightRepository.bookFlight(data);


      Get.snackbar("Success", "Flight booked successfully!");
      return true;
    } catch (e) {
      Get.snackbar("Booking Failed", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  void sortFlights(String type) {
    selectedSortType.value = type;
    if (type == 'low') {
      searchResults.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
      flightList.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
    } else if (type == 'high') {
      searchResults.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
      flightList.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
    } else {
      // Default: Restore original lists
      flightList.value = List.from(_originalFlightList);
      searchResults.value = List.from(_originalSearchResults);
    }
    searchResults.refresh();
    flightList.refresh();
  }
}
