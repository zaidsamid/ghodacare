import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = "GhodaCare";
  static const String appTagline = "Thyroid Symptom Tracker";

  // API Configuration
  static const String baseUrl =
      "http://10.0.2.2:8000/api"; // Local development server URL for Android emulator
  static const String infermedicaApiUrl =
      "https://api.infermedica.com/v3"; // Infermedica API URL
  static const String infermedicaAppId = "7158cb2c";
  static const String infermedicaAppKey = "d8a13aac51b54186e716fa5a400222f7";

  // Feature Flags
  static const bool kUseMockData = false; // Set to false to use real API calls

  // Colors
  static const Color primaryColor = Color(0xFF8121D3); // Purple
  static const Color primaryLightColor = Color(0xFFA05FE0);
  static const Color secondaryColor = Color(0xFF03DAC6); // Teal
  static const Color accentColor = Color(0xFF00B0FF); // Light Blue
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color cardColor = Colors.white;
  static const Color textDarkColor = Color(0xFF212121); // Dark Gray
  static const Color textLightColor = Color(0xFF757575); // Medium Gray
  static const Color errorColor = Color(0xFFB00020); // Red

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: textDarkColor,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: textDarkColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 16.0,
    color: textDarkColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14.0,
    color: textLightColor,
  );

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double buttonRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double inputRadius = 8.0;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(milliseconds: 2500);
}
