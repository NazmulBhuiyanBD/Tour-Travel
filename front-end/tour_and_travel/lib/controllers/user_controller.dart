import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/storage_service.dart';
import '../models/user_model.dart';
import '../core/constant/app_colors.dart';
import 'auth_controller.dart';

class UserController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final AuthController _authController = Get.find<AuthController>();

  var isLoading = false.obs;

  Future<void> updateProfile(String name, String phone) async {
    try {
      isLoading.value = true;
      Map<String, String> data = {
        "name": name,
        "phone": phone,
      };

      await _userRepository.updateProfile(data);

      // Update local storage and AuthController's user
      UserModel? currentUser = StorageService.to.getUser();
      if (currentUser != null) {
        currentUser.name = name;
        // Phone isn't in UserModel but we could add it if needed
        await StorageService.to.setUser(currentUser);
        _authController.user.value = currentUser;
      }

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
