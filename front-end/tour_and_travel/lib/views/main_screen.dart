import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view_models/auth_view_model.dart';
import '../core/constant/app_colors.dart';
import 'common_widgets/app_drawer.dart';
import 'dashboard/dashboard_screen.dart';
import 'flight/flight_search_screen.dart';
import 'flight/flight_list_screen.dart';
import 'hotel/hotel_list_screen.dart';
import 'tour/tour_list_screen.dart';

class MainNavigationController extends GetxController {
  var currentIndex = 0.obs;
  
  void changeTabIndex(int index) {
    currentIndex.value = index;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthViewModel authViewModel = Get.find<AuthViewModel>();
  final MainNavigationController navController = Get.put(MainNavigationController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(scaffoldKey: _scaffoldKey),
      FlightListScreen(scaffoldKey: _scaffoldKey),
      HotelListScreen(scaffoldKey: _scaffoldKey),
      TourListScreen(scaffoldKey: _scaffoldKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FE),
      drawer: const AppDrawer(),
      body: Obx(() => _pages[navController.currentIndex.value]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Obx(() => BottomNavigationBar(
          currentIndex: navController.currentIndex.value,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.navSelected,
          unselectedItemColor: AppColors.navUnselected,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: (index) {
            if (index == 4) {
              authViewModel.logout();
            } else {
              navController.changeTabIndex(index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_outlined),
              activeIcon: Icon(Icons.flight),
              label: "Flights",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hotel_outlined),
              activeIcon: Icon(Icons.hotel),
              label: "Hotels",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tour_outlined),
              activeIcon: Icon(Icons.tour),
              label: "Tours",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout_outlined),
              activeIcon: Icon(Icons.logout),
              label: "Logout",
            ),
          ],
        )),
      ),
    );
  }
}