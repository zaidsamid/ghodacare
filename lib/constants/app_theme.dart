import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      fontFamily: GoogleFonts.leagueSpartan().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.leagueSpartan(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: GoogleFonts.leagueSpartanTextTheme().copyWith(
        displayLarge: GoogleFonts.leagueSpartan(
          color: AppConstants.textDarkColor,
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.leagueSpartan(
          color: AppConstants.textDarkColor,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.leagueSpartan(
          color: AppConstants.textDarkColor,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.leagueSpartan(
          color: AppConstants.textDarkColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.leagueSpartan(
          color: AppConstants.textDarkColor,
          fontSize: 16.0,
        ),
        bodyMedium: GoogleFonts.leagueSpartan(
          color: AppConstants.textDarkColor,
          fontSize: 14.0,
        ),
        bodySmall: GoogleFonts.leagueSpartan(
          color: AppConstants.textLightColor,
          fontSize: 12.0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: GoogleFonts.leagueSpartan(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: BorderSide(color: AppConstants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
          textStyle: GoogleFonts.leagueSpartan(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          textStyle: GoogleFonts.leagueSpartan(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(color: AppConstants.errorColor),
        ),
        hintStyle: GoogleFonts.leagueSpartan(
          color: AppConstants.textLightColor,
          fontSize: 14.0,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    // TODO: Implement dark theme
    return lightTheme();
  }
}
