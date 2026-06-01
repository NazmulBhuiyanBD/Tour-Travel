import 'package:get/get.dart';
import '../data/repositories/tour_repository.dart';

class TourViewModel extends GetxController {
  final TourRepository _tourRepository = TourRepository();

  var isLoading = false.obs;
  var tourList = [].obs;
  var searchResults = [].obs;
  var _originalTourList = [];
  var _originalSearchResults = [];
  var searchQuery = ''.obs;
  var selectedSortType = 'default'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTours();
  }

  Future<void> fetchTours() async {
    try {
      isLoading(true);
      final response = await _tourRepository.getAllTours();
      final upcomingTours = _upcomingTours(response);
      tourList.value = upcomingTours;
      _originalTourList = List.from(upcomingTours);
      if (searchQuery.value.isEmpty) {
        searchResults.value = upcomingTours;
        _originalSearchResults = List.from(upcomingTours);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  void searchTours(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.value = tourList;
      _originalSearchResults = List.from(tourList);
    } else {
      final results = tourList
          .where(
            (tour) =>
                (tour['title'] ?? '').toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (tour['location'] ?? '').toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
      searchResults.value = results;
      _originalSearchResults = List.from(results);
    }
  }

  void sortTours(String type) {
    selectedSortType.value = type;
    if (type == 'low') {
      searchResults.sort(
        (a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0),
      );
      tourList.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
    } else if (type == 'high') {
      searchResults.sort(
        (a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0),
      );
      tourList.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
    } else {
      tourList.value = List.from(_originalTourList);
      searchResults.value = List.from(_originalSearchResults);
    }
    searchResults.refresh();
    tourList.refresh();
  }

  Future<bool> bookTour(
    int tourId,
    String transactionId,
    String paymentMethod, {
    int participantCount = 1,
  }) async {
    try {
      isLoading(true);
      Map<String, dynamic> data = {
        'tourId': tourId,
        'participantCount': participantCount.clamp(1, 4),
        'transactionId': transactionId,
        'paymentMethod': paymentMethod,
      };

      await _tourRepository.bookTour(data);
      await refreshCurrentTours();

      Get.snackbar("Success", "Tour booked successfully!");
      return true;
    } catch (e) {
      Get.snackbar("Booking Failed", e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshCurrentTours() async {
    final currentSearch = searchQuery.value;
    final currentSort = selectedSortType.value;

    final response = await _tourRepository.getAllTours();
    final upcomingTours = _upcomingTours(response);
    tourList.value = upcomingTours;
    _originalTourList = List.from(upcomingTours);

    searchTours(currentSearch);

    if (currentSort != 'default') {
      sortTours(currentSort);
    } else {
      tourList.refresh();
      searchResults.refresh();
    }
  }

  List<dynamic> _upcomingTours(dynamic response) {
    if (response is! List) return [];
    final today = _dateOnly(DateTime.now());

    return response.where((tour) {
      if (tour is! Map) return false;
      final startDate = _parseDateTime(tour['startDate']);
      if (startDate == null) return false;
      return !_dateOnly(startDate).isBefore(today);
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
