// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/utils/shared_pref_util.dart';
import 'package:ghodacare/screens/auth/login_screen.dart';

// Define a transparent image placeholder
final Uint8List kTransparentImage = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82
]);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      imagePath: 'assets/images/splash1.png',
      title: 'Everything at your fingertips',
      description: 'To your desire',
      icon: Icons.medical_services,
      color: Colors.purple,
    ),
    OnboardingPage(
      imagePath: 'assets/images/splash2.png',
      title: 'Get early detection for thyroid',
      description: 'To a healthier life',
      icon: Icons.healing,
      color: Colors.blue,
    ),
    OnboardingPage(
      imagePath: 'assets/images/splash3.png',
      title: 'Chart your bloodwork',
      description: 'All in one place',
      icon: Icons.bloodtype,
      color: Colors.red,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() async {
    // Mark first-time flag as false and set welcome screen as seen
    await SharedPrefUtil.setFirstTime(false);
    await SharedPrefUtil.setWelcomeScreenSeen();

    if (!mounted) return;

    // Navigate to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _numPages,
                itemBuilder: (context, index) {
                  return _pages[index].build();
                },
              ),
            ),

            // Bottom controls - page indicator and next button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _numPages,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppConstants.primaryColor,
                      dotColor: Colors.grey,
                      dotWidth: 8,
                      dotHeight: 8,
                      spacing: 4,
                    ),
                  ),

                  // Next button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _numPages - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(
                      _currentPage < _numPages - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.color,
  });

  Widget build() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image section
          Expanded(
            flex: 3,
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage(imagePath),
              imageErrorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 120,
                      color: color,
                    ),
                  ),
                );
              },
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 40),

          // Text content aligned to the left
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title - larger font
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Bottom space
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
