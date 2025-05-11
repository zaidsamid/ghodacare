import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/language_provider.dart';

import '../tabs/home_tab.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/wellness_tab.dart';
import '../tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  final int selectedIndex;

  const HomeScreen({super.key, this.selectedIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  // List of tabs, correctly typed
  final List<Widget> _tabs = [
    const HomeTab(),
    const DashboardTab(),
    const WellnessTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex; // Initialize current tab index
  }

  // On tab tapped, update the index
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        body: _tabs[_currentIndex], // Load the selected tab
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: languageProvider.get('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: languageProvider.get('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/wellness icon.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.spa,
                    color:
                        _currentIndex == 2 ? Colors.purple : Colors.grey[400],
                    size: 24,
                  );
                },
              ),
              activeIcon: Image.asset(
                'assets/images/wellness icon.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.spa,
                    color: Colors.purple,
                    size: 24,
                  );
                },
              ),
              label: languageProvider.get('wellness'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: languageProvider.get('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
