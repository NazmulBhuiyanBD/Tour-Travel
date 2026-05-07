import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/main_screen.dart';
import './data/services/storage_service.dart';
import './controllers/auth_controller.dart';
import './routes/app_pages.dart';
import './routes/app_routes.dart';
import './core/theme/app_theme.dart';
import './models/user_model.dart';
import './views/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  Get.put(AuthController()); // Initialize AuthController globally
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    
    if (!seenOnboarding) {
      return Routes.ONBOARDING;
    }
    
    String? token = StorageService.to.getToken();
    if (token != null) {
      UserModel? user = StorageService.to.getUser();
      if (user != null && (user.role == 'Admin' || user.role == 'SuperAdmin')) {
        return Routes.ADMIN_DASHBOARD;
      }
      return Routes.DASHBOARD;
    }
    
    return Routes.LOGIN;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( 
      debugShowCheckedModeBanner: false,
      title: 'NAZTRAVEL',
      theme: AppTheme.lightTheme,
      getPages: AppPages.routes,
      home: FutureBuilder<String>(
        future: checkInitialState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
              ),
            );
          }
          
          if (snapshot.data == Routes.DASHBOARD) {
            return const MainScreen();
          } else if (snapshot.data == Routes.ADMIN_DASHBOARD) {
            return const AdminDashboardScreen();
          } else if (snapshot.data == Routes.LOGIN) {
            return LoginScreen();
          } else {
            return OnboardingScreen();
          }
        },
      ),
    );
  }
}