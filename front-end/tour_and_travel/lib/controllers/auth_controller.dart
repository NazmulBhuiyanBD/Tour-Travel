import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_and_travel/data/services/storage_service.dart';
import '../models/user_model.dart';
import '../data/repositories/auth_repository.dart';

import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  
  var isLoading = false.obs;
  var user = UserModel().obs;

  @override
  void onInit() {
    super.onInit();
    // Hydrate user data from storage on startup
    UserModel? savedUser = StorageService.to.getUser();
    if (savedUser != null) {
      user.value = savedUser;
    }
  }

  // LOGIN LOGIC
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter all fields", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Map<String, String> data = {
        'email': email,
        'password': password,
      };

      final response = await _authRepository.loginApi(data);

      // Parse response into our Model
      user.value = UserModel.fromJson(response);

      // Save token and user info to local storage
      if (user.value.token != null) {
        await StorageService.to.setToken(user.value.token!);
        await StorageService.to.setUser(user.value);
      }

      Get.snackbar("Success", "Welcome ${user.value.name}", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white);
      
      // Navigate to Dashboard or Home
      if (user.value.role == 'Admin') {
        Get.offAllNamed(Routes.ADMIN_DASHBOARD);
      } else {
        Get.offAllNamed(Routes.DASHBOARD); 
      }
    } catch (e) {
      if (e.toString().contains("EmailNotConfirmed")) {
        Get.toNamed(Routes.VERIFY_EMAIL, arguments: email);
        Get.snackbar("Notice", "Your account is not verified. Please enter the verification code.", 
            snackPosition: SnackPosition.BOTTOM, 
            backgroundColor: Colors.orange, 
            colorText: Colors.white);
      } else {
        Get.snackbar("Login Failed", e.toString(), 
            snackPosition: SnackPosition.BOTTOM, 
            backgroundColor: Colors.red, 
            colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ADMIN LOGIN LOGIC
  Future<void> adminLogin(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter all fields", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Map<String, String> data = {
        'email': email,
        'password': password,
      };

      final response = await _authRepository.adminLoginApi(data);

      user.value = UserModel.fromJson(response);

      if (user.value.token != null) {
        await StorageService.to.setToken(user.value.token!);
        await StorageService.to.setUser(user.value);
      }

      Get.snackbar("Success", "Admin Acccess Granted", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white);
      
      Get.offAllNamed(Routes.ADMIN_DASHBOARD); 
    } catch (e) {
      Get.snackbar("Login Failed", "Invalid admin credentials", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // SIGNUP LOGIC
  Future<void> register(String name, String email, String password, String phone) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Map<String, String> data = {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone
      };

      final res = await _authRepository.registerApi(data);
      debugPrint("Registration Response: $res");

      // Navigate to Verification screen
      Get.toNamed(Routes.VERIFY_EMAIL, arguments: email);
      
      Get.snackbar("Success", "Registered successfully. Please enter the code sent to your email.", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(), 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // VERIFY EMAIL LOGIC
  Future<void> verifyEmail(String email, String token) async {
    if (token.isEmpty) {
      Get.snackbar("Error", "Please enter the verification code", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Map<String, String> data = {
        "email": email,
        "token": token
      };

      await _authRepository.verifyEmailApi(data);
      
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar("Success", "Email verified successfully. You can now login.", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Verification Failed", e.toString(), 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // FORGOT PASSWORD LOGIC
  Future<void> forgotPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Map<String, String> data = {
        "email": email
      };

      await _authRepository.forgotPasswordApi(data);
      
      Get.toNamed(Routes.RESET_PASSWORD, arguments: email);
      Get.snackbar("Success", "Reset code sent to your email.", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(), 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // RESET PASSWORD LOGIC
  Future<void> resetPassword(String email, String token, String newPassword) async {
    if (token.isEmpty || newPassword.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Map<String, String> data = {
        "email": email,
        "token": token,
        "newPassword": newPassword
      };

      await _authRepository.resetPasswordApi(data);
      
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar("Success", "Password reset successfully. You can now login.", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Reset Failed", e.toString(), 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // CHANGE PASSWORD LOGIC
  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      Map<String, String> data = {
        "email": email,
        "oldPassword": oldPassword,
        "newPassword": newPassword
      };

      await _authRepository.changePasswordApi(data);
      
      Get.back(); // close dialog
      Get.snackbar("Success", "Password updated successfully", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(), 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // LOGOUT LOGIC
  Future<void> logout() async {
    await StorageService.to.clear();
    user.value = UserModel();
    Get.offAllNamed(Routes.LOGIN);
    Get.snackbar("Logged Out", "You have been successfully logged out", 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.blueAccent, 
        colorText: Colors.white);
  }
}