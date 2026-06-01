import 'package:get/get.dart';
import '../data/repositories/flight_repository.dart';

class FlightViewModel extends GetxController {
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
      final upcomingFlights = _upcomingFlights(response);
      flightList.value = upcomingFlights;
      _originalFlightList = List.from(upcomingFlights);
      // Ensure search results are seeded with all flights if no filter set.
      if (searchResults.isEmpty) {
        searchResults.value = upcomingFlights;
        _originalSearchResults = List.from(upcomingFlights);
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

      if (from.isEmpty || to.isEmpty) {
        searchResults.value = List.from(flightList);
        _originalSearchResults = List.from(flightList);
        return;
      }

      final response = await _flightRepository.searchFlights(from, to);
      final upcomingFlights = _upcomingFlights(response);
      searchResults.value = upcomingFlights;
      _originalSearchResults = List.from(upcomingFlights);
    } catch (e) {
      Get.snackbar("Search Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  var seatClasses = <dynamic>[].obs;
  var selectedSeatClass = 'Economy'.obs;

  Future<void> fetchSeatClasses(int flightId) async {
    try {
      final response = await _flightRepository.getSeatClasses(flightId);
      seatClasses.value = response is List ? response : [];
      if (seatClasses.isNotEmpty) {
        selectedSeatClass.value = seatClasses.first['className'] ?? 'Economy';
      }
    } catch (e) {
      seatClasses.value = [];
    }
  }

  Future<bool> bookFlight(
    int flightId,
    int seats,
    String transactionId,
    String paymentMethod, {
    String? seatClass,
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {
        'flightId': flightId,
        'seatClass': seatClass ?? selectedSeatClass.value,
        'seatCount': seats.clamp(1, 4),
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
      };

      await _flightRepository.bookFlight(data);
      await refreshCurrentFlights();

      Get.snackbar("Success", "Flight booked successfully!");
      return true;
    } catch (e) {
      Get.snackbar("Booking Failed", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshCurrentFlights() async {
    final currentFrom = fromCity.value;
    final currentTo = toCity.value;
    final currentSort = selectedSortType.value;

    final response = await _flightRepository.getAllFlights();
    final upcomingFlights = _upcomingFlights(response);
    flightList.value = upcomingFlights;
    _originalFlightList = List.from(upcomingFlights);

    if (currentFrom.isNotEmpty && currentTo.isNotEmpty) {
      final searchResponse = await _flightRepository.searchFlights(
        currentFrom,
        currentTo,
      );
      final upcomingSearchResults = _upcomingFlights(searchResponse);
      searchResults.value = upcomingSearchResults;
      _originalSearchResults = List.from(upcomingSearchResults);
    } else {
      searchResults.value = List.from(upcomingFlights);
      _originalSearchResults = List.from(upcomingFlights);
    }

    if (currentSort != 'default') {
      sortFlights(currentSort);
    } else {
      flightList.refresh();
      searchResults.refresh();
    }
  }

  void sortFlights(String type) {
    selectedSortType.value = type;
    if (type == 'low') {
      searchResults.sort(
        (a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0),
      );
      flightList.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
    } else if (type == 'high') {
      searchResults.sort(
        (a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0),
      );
      flightList.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
    } else {
      // Default: Restore original lists
      flightList.value = List.from(_originalFlightList);
      searchResults.value = List.from(_originalSearchResults);
    }
    searchResults.refresh();
    flightList.refresh();
  }

  List<dynamic> _upcomingFlights(dynamic response) {
    if (response is! List) return [];
    final today = _dateOnly(DateTime.now());

    return response.where((flight) {
      if (flight is! Map) return false;
      final departure = _parseDateTime(flight['departureTime']);
      if (departure == null) return false;
      return !_dateOnly(departure).isBefore(today);
    }).toList();
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);
}
