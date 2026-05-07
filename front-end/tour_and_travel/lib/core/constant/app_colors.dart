import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primaryBlue = Color(0xFF3F51B5);
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color primaryLight = Color(0xFF7986CB);

  // Accent
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentGold = Color(0xFFFFC107);

  // Background
  static const Color scaffoldBg = Color(0xFFF5F7FA);
  static const Color white = Colors.white;
  static const Color cardBg = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Dashboard Summary Cards
  static const Color cardBlue = Color(0xFF3F51B5);
  static const Color cardYellow = Color(0xFFFFC107);
  static const Color cardGreen = Color(0xFF4CAF50);

  // Status
  static const Color confirmed = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFFC107);
  static const Color cancelled = Color(0xFFF44336);

  // Gradient for welcome card
  static const LinearGradient welcomeGradient = LinearGradient(
    colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient for header curves
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0), Color(0xFF7986CB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Drawer
  static const Color drawerIcon = Color(0xFF616161);
  static const Color phoneBadge = Color(0xFF4CAF50);

  // Bottom Nav
  static const Color navSelected = Color(0xFF3F51B5);
  static const Color navUnselected = Color(0xFF9E9E9E);

  // Stars
  static const Color starColor = Color(0xFFFF9800);

  // Filter button
  static const Color filterOrange = Color(0xFFFF9800);

  // Counter buttons
  static const Color counterRed = Color(0xFFE53935);
}
