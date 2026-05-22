import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/storage_service.dart';
import '../models/user_model.dart';
import '../core/constant/app_colors.dart';
import 'auth_view_model.dart';

class UserViewModel extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final AuthViewModel _authViewModel = Get.find<AuthViewModel>();

  var isLoading = false.obs;

  Future<void> updateProfile(String name, String phone, String gender, String dateOfBirth, String address, String? profilePicture) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> data = {
        "name": name,
        "phone": phone,
        "gender": gender,
        "dateOfBirth": dateOfBirth,
        "address": address,
        "profilePicture": profilePicture,
      };

      await _userRepository.updateProfile(data);

      // Update local storage and AuthViewModel's user
      UserModel? currentUser = StorageService.to.getUser();
      if (currentUser != null) {
        currentUser.name = name;
        currentUser.phone = phone;
        currentUser.gender = gender;
        currentUser.dateOfBirth = dateOfBirth;
        currentUser.address = address;
        currentUser.profilePicture = profilePicture;
        await StorageService.to.setUser(currentUser);
        _authViewModel.user.value = currentUser;
      }

      // Sync user profile from database to ensure everything matches database state
      await _authViewModel.fetchUserProfile();

      Get.defaultDialog(
        title: "Profile Updated",
        middleText: "Your information has been successfully updated.",
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
        middleTextStyle: const TextStyle(color: AppColors.textPrimary),
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: AppColors.primaryBlue,
        onConfirm: () {
          Get.back(); // Close dialog
          Get.back(); // Go back to Dashboard/Drawer
        },
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
