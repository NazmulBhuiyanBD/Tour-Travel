import 'package:get/get.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardViewModel extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  var topDestinations = <dynamic>[].obs;
  var popularAirlines = <dynamic>[].obs;
  var featuredHotels = <dynamic>[].obs;

  var isLoadingTop = false.obs;
  var isLoadingAirlines = false.obs;
  var isLoadingHotels = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  void fetchAll() {
    fetchTopDestinations();
    fetchPopularAirlines();
    fetchFeaturedHotels();
  }

  Future<void> fetchTopDestinations() async {
    isLoadingTop.value = true;
    try {
      final response = await _repository.getTopDestinations();
      topDestinations.value = _upcomingItems(response, 'startDate');
    } catch (e) {
      print("Error fetching top destinations: $e");
    } finally {
      isLoadingTop.value = false;
    }
  }

  Future<void> fetchPopularAirlines() async {
    isLoadingAirlines.value = true;
    try {
      final response = await _repository.getPopularAirlines();
      popularAirlines.value = _upcomingItems(response, 'departureTime');
    } catch (e) {
      print("Error fetching popular airlines: $e");
    } finally {
      isLoadingAirlines.value = false;
    }
  }

  Future<void> fetchFeaturedHotels() async {
    isLoadingHotels.value = true;
    try {
      final response = await _repository.getFeaturedHotels();
      featuredHotels.value = response;
    } catch (e) {
      print("Error fetching featured hotels: $e");
    } finally {
      isLoadingHotels.value = false;
    }
  }

  List<dynamic> _upcomingItems(dynamic response, String dateKey) {
    if (response is! List) return [];
    final today = _dateOnly(DateTime.now());

    return response.where((item) {
      if (item is! Map) return false;
      final date = _parseDateTime(item[dateKey]);
      if (date == null) return false;
      return !_dateOnly(date).isBefore(today);
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
