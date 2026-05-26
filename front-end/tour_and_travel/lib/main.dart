import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './data/services/storage_service.dart';
import './view_models/auth_view_model.dart';
import './routes/app_pages.dart';
import './routes/app_routes.dart';
import './core/theme/app_theme.dart';
import './models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  Get.put(AuthViewModel()); // Initialize AuthViewModel globally

  // Determine the initial route BEFORE runApp
  final initialRoute = await _determineInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  if (!seenOnboarding) {
    return Routes.ONBOARDING;
  }

  String? token = StorageService.to.getToken();
  if (token != null) {
    UserModel? user = StorageService.to.getUser();
    if (user != null && user.role == 'Admin') {
      return Routes.ADMIN_DASHBOARD;
    }
    return Routes.DASHBOARD;
  }

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