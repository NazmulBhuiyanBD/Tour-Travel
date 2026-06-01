import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './data/services/storage_service.dart';
import './view_models/auth_view_model.dart';
import './routes/app_pages.dart';
import './routes/app_routes.dart';
import './core/theme/app_theme.dart';
import './models/user_model.dart';
import './data/repositories/user_repository.dart';
import './data/repositories/admin_repository.dart';
import './data/api/app_exceptions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  Get.put(AuthViewModel()); // Initialize AuthViewModel globally

  // Determine the initial route BEFORE runApp
  final initialRoute = await _determineInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

bool _isSessionExpiredError(Object error) {
  final message = error.toString().toLowerCase();
  return error is UnauthorisedException ||
      message.contains("unauthorised request") ||
      message.contains("unauthorized") ||
      message.contains("session expired") ||
      message.contains("invalid email or password") ||
      message.contains("not found") ||
      message.contains("404");
}

Future<String> _determineInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  if (!seenOnboarding) {
    return Routes.ONBOARDING;
  }

  String? token = StorageService.to.getToken();
  UserModel? user = StorageService.to.getUser();

  if (token != null && user != null) {
    if (user.role != 'Admin') {
      try {
        final UserRepository userRepository = UserRepository();
        final response = await userRepository.getProfile().timeout(const Duration(seconds: 4));
        if (response != null) {
          UserModel updatedUser = UserModel.fromJson(response);
          updatedUser.token = token;
          await StorageService.to.setUser(updatedUser);
          if (Get.isRegistered<AuthViewModel>()) {
            Get.find<AuthViewModel>().user.value = updatedUser;
          }
          return Routes.DASHBOARD;
        }
      } catch (e) {
        print("Startup user session validation failed: $e");
        if (_isSessionExpiredError(e)) {
          await StorageService.to.clear();
          if (Get.isRegistered<AuthViewModel>()) {
            Get.find<AuthViewModel>().user.value = UserModel();
          }
          return Routes.LOGIN;
        }
        // If it's a simple network issue/timeout, allow offline/cached dashboard access
        return Routes.DASHBOARD;
      }
    } else {
      // Validate Admin via dashboard stats API call
      try {
        final AdminRepository adminRepository = AdminRepository();
        final response = await adminRepository.getDashboardStats().timeout(const Duration(seconds: 4));
        if (response != null) {
          return Routes.ADMIN_DASHBOARD;
        }
      } catch (e) {
        print("Startup admin session validation failed: $e");
        if (_isSessionExpiredError(e)) {
          await StorageService.to.clear();
          if (Get.isRegistered<AuthViewModel>()) {
            Get.find<AuthViewModel>().user.value = UserModel();
          }
          return Routes.LOGIN;
        }
        // Network timeout / offline: allow cached dashboard access
        return Routes.ADMIN_DASHBOARD;
      }
    }
  }

  // If credentials are incomplete or corrupt, ensure storage is clean and prompt login
  await StorageService.to.clear();
  return Routes.LOGIN;
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NAZTRAVEL',
      theme: AppTheme.lightTheme,
      getPages: AppPages.routes,
      initialRoute: initialRoute,
    );
  }
}