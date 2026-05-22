import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tour_and_travel/core/constant/api_constants.dart';
import '../data/repositories/admin_repository.dart';

class AdminManagementViewModel extends GetxController {
  final AdminRepository _repository = AdminRepository();

  var users = <dynamic>[].obs;
  var tours = <dynamic>[].obs;
  var hotels = <dynamic>[].obs;
  var flights = <dynamic>[].obs;

  var hotelBookings = <dynamic>[].obs;
  var flightBookings = <dynamic>[].obs;
  var tourBookings = <dynamic>[].obs;
  
  var isLoading = false.obs;
  var selectedHotelImagePath = ''.obs;
  var selectedTourImagePath = ''.obs;
  var isUploading = false.obs;
  var dashboardData = <String, dynamic>{}.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  void refreshAll() {
    fetchUsers();
    fetchTours();
    fetchHotels();
    fetchFlights();

    fetchHotelBookings();
    fetchFlightBookings();
    fetchTourBookings();
    fetchDashboardData();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  // Users
  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      dynamic response = await _repository.getUsers();
      users.value = response;
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleUserStatus(int id) async {
    try {
      await _repository.toggleUserStatus(id);
      fetchUsers();
      _showSuccess('User status updated');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      fetchUsers();
      _showSuccess('User deleted');
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Super Admins
  var adminsList = <dynamic>[].obs;
  
  Future<void> fetchAdmins() async {
    isLoading.value = true;
    try {
      dynamic response = await _repository.getAdmins();
      adminsList.value = response;
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAdmin(dynamic data) async {
    try {
      await _repository.createAdmin(data);
      fetchAdmins();
      Get.back();
      _showSuccess('Admin account created');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteAdmin(int id) async {
    try {
      await _repository.deleteAdmin(id);
      fetchAdmins();
      _showSuccess('Admin deleted');
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Tours
  Future<void> fetchTours() async {
    try {
      dynamic response = await _repository.getTours();
      tours.value = response;
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> addTour(dynamic data) async {
    try {
      await _repository.createTour(data);
      fetchTours();
      Get.back();
      _showSuccess('Tour added');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> updateTour(int id, dynamic data) async {
    try {
      await _repository.updateTour(id, data);
      fetchTours();
      Get.back();
      _showSuccess('Tour updated');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteTour(int id) async {
    try {
      await _repository.deleteTour(id);
      fetchTours();
      _showSuccess('Tour deleted');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> pickAndUploadTourImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      isUploading.value = true;
      File file = File(image.path);
      
      dynamic response = await _repository.uploadImage(file);
      if (response != null && response['path'] != null) {
        selectedTourImagePath.value = response['path'];
        _showSuccess('Tour image uploaded successfully');
      }
    } catch (e) {
      _showError('Upload failed: ${e.toString()}');
    } finally {
      isUploading.value = false;
    }
  }

  // Hotels
  Future<void> fetchHotels() async {
    try {
      dynamic response = await _repository.getHotels();
      hotels.value = response;
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> addHotel(dynamic data) async {
    try {
      await _repository.createHotel(data);
      fetchHotels();
      Get.back();
      _showSuccess('Hotel added');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> updateHotel(int id, dynamic data) async {
    try {
      await _repository.updateHotel(id, data);
      fetchHotels();
      Get.back();
      _showSuccess('Hotel updated');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> pickAndUploadHotelImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      isUploading.value = true;
      File file = File(image.path);
      
      dynamic response = await _repository.uploadImage(file);
      if (response != null && response['path'] != null) {
        selectedHotelImagePath.value = response['path'];
        _showSuccess('Image uploaded successfully');
      }
    } catch (e) {
      _showError('Upload failed: ${e.toString()}');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteHotel(int id) async {
    try {
      await _repository.deleteHotel(id);
      fetchHotels();
      _showSuccess('Hotel deleted');
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Flights
  Future<void> fetchFlights() async {
    try {
      dynamic response = await _repository.getFlights();
      flights.value = response;
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> addFlight(dynamic data) async {
    try {
      await _repository.createFlight(data);
      fetchFlights();
      Get.back();
      _showSuccess('Flight added');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> updateFlight(int id, dynamic data) async {
    try {
      await _repository.updateFlight(id, data);
      fetchFlights();
      Get.back();
      _showSuccess('Flight updated');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> deleteFlight(int id) async {
    try {
      await _repository.deleteFlight(id);
      fetchFlights();
      _showSuccess('Flight deleted');
    } catch (e) {
      _showError(e.toString());
    }
  }


  // Bookings
  Future<void> fetchHotelBookings() async {
    try {
      dynamic response = await _repository.getHotelBookings();
      hotelBookings.value = response;
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> fetchFlightBookings() async {
    try {
      dynamic response = await _repository.getFlightBookings();
      flightBookings.value = response;
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> fetchTourBookings() async {
    try {
      dynamic response = await _repository.getTourBookings();
      tourBookings.value = response;
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> toggleTopTour(int id) async {
    try {
      await _repository.toggleTopTour(id);
      fetchTours();
      _showSuccess('Tour highlight updated');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> toggleFeaturedHotel(int id) async {
    try {
      await _repository.toggleFeaturedHotel(id);
      fetchHotels();
      _showSuccess('Hotel highlight updated');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> togglePopularFlight(int id) async {
    try {
      await _repository.togglePopularFlight(id);
      fetchFlights();
      _showSuccess('Flight highlight updated');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      dynamic response = await _repository.getDashboardStats();
      if (response != null) {
        dashboardData.value = Map<String, dynamic>.from(response);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }
}

