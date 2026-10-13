import 'package:flutter/material.dart';

import '../enums/trip_type.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1976D2);

  // Trip Type Colors
  static const Color business = Color(0xFF5E35B1);
  static const Color leisure = Color(0xFF00ACC1);
  static const Color adventure = Color(0xFFFF6F00);
  static const Color cultural = Color(0xFFD81B60);
  static const Color romantic = Color(0xFFE91E63);
  static const Color family = Color(0xFF43A047);

  // Functional Colors
  static const Color weather = Color(0xFF42A5F5);
  static const Color weatherDark = Color(0xFF1E88E5);
  static const Color transport = Color(0xFFFF9800);
  static const Color transportLight = Color(0xFFFFB74D);
  static const Color budget = Color(0xFF4CAF50);
  static const Color budgetLight = Color(0xFF66BB6A);
  static const Color accommodation = Color(0xFF2196F3);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Light Theme Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Light Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // Light Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFBDBDBD);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextHint = Color(0xFF808080);
  static const Color darkTextDisabled = Color(0xFF606060);

  // Dark Border Colors
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkBorderLight = Color(0xFF303030);
  static const Color darkDivider = Color(0xFF404040);

  // Shadow Colors
  static Color shadow = Colors.black.withAlpha(10);
  static Color shadowMedium = Colors.black.withAlpha(20);
  static Color shadowDark = Colors.black.withAlpha(31);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];

  static const List<Color> weatherGradient = [
    Color(0xFF42A5F5),
    Color(0xFF1E88E5),
  ];

  static const List<Color> budgetGradient = [
    Color(0xFF4CAF50),
    Color(0xFF66BB6A),
  ];

  static Color getTripTypeColor(TripType type) {
    switch (type) {
      case TripType.business:
        return business;
      case TripType.relaxation:
        return leisure;
      case TripType.adventure:
        return adventure;
      case TripType.cultural:
        return cultural;
      case TripType.romantic:
        return romantic;
      case TripType.family:
        return family;
    }
  }

  static List<Color> getTripTypeGradient(TripType type) {
    final baseColor = getTripTypeColor(type);
    return [baseColor, baseColor.withAlpha(178)];
  }
}
