// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/utils/shared_pref_util.dart';
import 'onboarding_screen.dart';
import 'package:ghodacare/screens/auth/login_screen.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    // Simulate loading delay
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    // Check if it's the first time opening the app
    final isFirstTime = await SharedPrefUtil.isFirstTime();

    if (isFirstTime) {
      // Navigate to onboarding screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      // Check if user is logged in
      final isLoggedIn = await SharedPrefUtil.isLoggedIn();

      if (isLoggedIn) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen(selectedIndex: 0)),
        );
      } else {
        // Navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // Determine background color and logo based on theme
    final Color backgroundColor =
        isDarkMode ? const Color(0xFF6A0DAD) : Colors.white;
    final String logoAsset = isDarkMode
        ? 'assets/images/darkmodeicon.png'
        : 'assets/images/appicon.png';
    final Color progressColor =
        isDarkMode ? Colors.white : AppConstants.primaryColor;
    final Color appNameColor =
        isDarkMode ? Colors.white : AppConstants.primaryColor;
    final Color taglineColor =
        isDarkMode ? Colors.white70 : AppConstants.textLightColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo (Conditional)
            Image.asset(
              logoAsset,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback in case darkmodeicon.png is missing
                return Image.asset('assets/images/appicon.png',
                    width: 150, height: 150, fit: BoxFit.contain);
              },
            ),
            const SizedBox(height: 24),

            // App Name (Conditional Color)
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: appNameColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Tagline (Conditional Color)
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                color: taglineColor,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // Loading indicator (Conditional Color)
            CircularProgressIndicator(
              color: progressColor,
            ),
          ],
        ),
      ),
    );
  }
}
