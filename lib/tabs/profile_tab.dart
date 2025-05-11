// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/providers/language_provider.dart';
import 'package:ghodacare/providers/theme_provider.dart';
import 'package:ghodacare/screens/auth/login_screen.dart';
import 'package:ghodacare/screens/profile/edit_profile_screen.dart';
import 'package:ghodacare/screens/profile/preferences_screen.dart';
import 'package:ghodacare/screens/profile/notifications_screen.dart';
import 'package:ghodacare/screens/profile/change_password_request_screen.dart';
import 'package:ghodacare/screens/profile/help_screen.dart';
import 'package:ghodacare/utils/shared_pref_util.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // State variables for user data
  String? _userName;
  String? _userEmail;
  String? _gender;
  String? _dob;
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    print("Reloading ProfileTab Data...");
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading

    // ✅ Fetch user info from Shared Preferences
    final firstName = await SharedPrefUtil.getUserFirstName();
    final lastName = await SharedPrefUtil.getUserLastName();
    final email = await SharedPrefUtil.getUserEmail();

    if (mounted) {
      setState(() {
        _userName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        _userEmail = email ?? '';
        _gender = _gender; // Keep previous gender (optional)
        _dob = _dob; // Keep previous DOB (optional)
        _avatarUrl = _avatarUrl; // Keep previous avatar
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        backgroundColor: themeProvider.themeData.scaffoldBackgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 60),
                  _buildProfileHeader(),
                  const SizedBox(height: 30),
                  _buildBasicInfoCard(themeProvider),
                  const SizedBox(height: 30),
                  _buildMenuItems(context, languageProvider, themeProvider),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage:
              _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
          child: _avatarUrl == null
              ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          _userName ?? 'Loading...', // Show loading or fetched name
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userEmail ?? '', // Show fetched email
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(ThemeProvider themeProvider) {
    final bool isDarkMode = themeProvider.isDarkMode;
    final cardColor =
        isDarkMode ? const Color(0xFF333333) : AppConstants.primaryColor;
    final textColor = Colors.white;
    final labelColor = isDarkMode ? Colors.grey.shade400 : Colors.white70;
    final valueColor = Colors.white;
    final placeholderColor = isDarkMode ? Colors.grey.shade500 : Colors.white54;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Info', // TODO: Localize
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Gender',
            _gender ?? 'Not Set',
            labelColor,
            _gender == null ? placeholderColor : valueColor,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Date of Birth',
            _dob ?? 'Not Set',
            labelColor,
            _dob == null ? placeholderColor : valueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, // TODO: Localize
          style: TextStyle(
            fontSize: 16,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context,
      LanguageProvider languageProvider, ThemeProvider themeProvider) {
    final listTileColor =
        themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final iconColor =
        themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: listTileColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            text: 'My Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen()),
              );
              if (result == true && mounted) {
                _loadUserData();
              }
            },
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildMenuItem(
            icon: Icons.tune_outlined,
            text: 'Preferences',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PreferencesScreen()),
              );
            },
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildMenuItem(
            icon: Icons.notifications_none_outlined,
            text: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen()),
              );
            },
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            text: 'Change Password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangePasswordRequestScreen()),
              );
            },
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            text: 'Help',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
            iconColor: iconColor,
            textColor: textColor,
          ),
          _buildMenuItem(
            icon: Icons.logout,
            text: 'Log Out',
            onTap: () {
              _showLogoutConfirmationDialog(context);
            },
            iconColor: iconColor,
            textColor: textColor,
            hideDivider: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required Color iconColor,
    required Color textColor,
    bool hideDivider = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.grey.shade400),
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        if (!hideDivider)
          Padding(
            padding: const EdgeInsets.only(left: 70, right: 20),
            child: Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          ),
      ],
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout(context);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    // TODO: Clear user session/data
    // await SharedPrefUtil.clearUserData();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
