import 'package:get/get.dart';
import 'package:tour_and_travel/views/admin/admin_featured_hotels_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/auth/admin_login_screen.dart';
import '../views/main_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/dashboard/user_dashboard_screen.dart';
import '../views/dashboard/booking_history_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/chat/chat_screen.dart';
import '../views/admin/admin_chat_list_screen.dart';
import '../views/admin/admin_user_manage_screen.dart';
import '../views/admin/admin_flight_manage_screen.dart';
import '../views/admin/admin_hotel_manage_screen.dart';
import '../views/admin/admin_tour_manage_screen.dart';
import '../views/admin/admin_booking_manage_screen.dart';
import '../views/admin/super_admin_manage_screen.dart';
import '../views/admin/admin_top_destinations_screen.dart';
import '../views/admin/admin_popular_airlines_screen.dart';
import '../views/auth/verify_email_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/auth/reset_password_screen.dart';
import '../views/tour/tour_details_screen.dart';
import '../views/hotel/hotel_details_screen.dart';
import '../views/dashboard/my_flight_bookings_screen.dart';
import '../views/dashboard/flight_booking_details_screen.dart';
import '../views/hotel/booking_success_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.TOUR_DETAILS,
      page: () => TourDetailsScreen(tourData: Get.arguments),
    ),
    GetPage(
      name: Routes.HOTEL_DETAILS,
      page: () => HotelDetailsScreen(hotelData: Get.arguments),
    ),
    GetPage(
      name: Routes.MY_FLIGHT_BOOKINGS,
      page: () => MyFlightBookingsScreen(),
    ),
    GetPage(
      name: Routes.FLIGHT_BOOKING_DETAILS,
      page: () => FlightBookingDetailsScreen(booking: Get.arguments),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupScreen(),
    ),
    GetPage(
      name: Routes.INITIAL,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const MainScreen(),
    ),
    GetPage(
      name: Routes.USER_DASHBOARD,
      page: () => UserDashboardScreen(),
    ),
    GetPage(
      name: Routes.BOOKING_HISTORY,
      page: () =>  BookingHistoryScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_LOGIN,
      page: () => AdminLoginScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_CHAT_LIST,
      page: () => const AdminChatListScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_CHAT,
      page: () => const ChatScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_USER_MANAGE,
      page: () => const AdminUserManageScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_FLIGHT_MANAGE,
      page: () => const AdminFlightManageScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_HOTEL_MANAGE,
      page: () => const AdminHotelManageScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_TOUR_MANAGE,
      page: () => const AdminTourManageScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_BOOKINGS,
      page: () => const AdminBookingManageScreen(),
    ),
    GetPage(
      name: Routes.SUPER_ADMIN_MANAGE,
      page: () => const SuperAdminManageScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_TOP_DESTINATIONS,
      page: () => const AdminTopDestinationsScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_POPULAR_AIRLINES,
      page: () => const AdminPopularAirlinesScreen(),
    ),
    GetPage(
      name: Routes.ADMIN_FEATURED_HOTELS,
      page: () => const AdminFeaturedHotelsScreen(),
    ),
    GetPage(
      name: Routes.VERIFY_EMAIL,
      page: () => VerifyEmailScreen(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => ResetPasswordScreen(),
    ),
    GetPage(
      name: Routes.BOOKING_SUCCESS,
      page: () => const BookingSuccessScreen(),
    ),
  ];
}
