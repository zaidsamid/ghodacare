import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/screens/profile/preferences_screen.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:ghodacare/utils/shared_pref_util.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _userName = 'User';
  String _email = 'user@example.com';
  String _dob = 'Not set';
  String _bloodType = 'Not set';
  String _height = 'Not set';
  String _weight = 'Not set';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // First try to get from shared preferences for faster loading
      final name = await SharedPrefUtil.getUserName();
      final email = await SharedPrefUtil.getUserEmail();

      if (name != null && email != null) {
        setState(() {
          _userName = name;
          _email = email;
        });
      }

      // Then load full profile from API
      final response = await _apiService.getUserProfile();

      if (response['success'] == true) {
        final userData = response['data'];

        setState(() {
          _userName = userData['name'] ?? 'User';
          _email = userData['email'] ?? 'user@example.com';
          _dob = userData['birth_date'] ?? 'Not set';
          _bloodType = userData['blood_type'] ?? 'Not set';
          _height = userData['height'] != null
              ? '${userData['height']} cm'
              : 'Not set';
          _weight = userData['weight'] != null
              ? '${userData['weight']} kg'
              : 'Not set';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (_errorMessage.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildProfileCard(),
                        const SizedBox(height: 16),
                        _buildHealthInfoCard(),
                        const SizedBox(height: 16),
                        _buildAccountOptions(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFE8E7F7),
              child: Text(
                _userName.isNotEmpty
                    ? _userName.substring(0, 1).toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );

                // Refresh data if profile was updated
                if (result == true) {
                  _loadUserData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date of Birth', _dob, Icons.cake_outlined),
            _buildInfoRow('Blood Type', _bloodType, Icons.bloodtype_outlined),
            _buildInfoRow('Height', _height, Icons.height_outlined),
            _buildInfoRow('Weight', _weight, Icons.monitor_weight_outlined),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to edit health info screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Update health info coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Update Health Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            'Preferences',
            Icons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreferencesScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            'Medical Records',
            Icons.folder_shared,
            onTap: () {
              // Navigate to medical records
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Medical records coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            'Doctor & Appointments',
            Icons.calendar_today,
            onTap: () {
              // Navigate to appointments
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointments coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            'Help & Support',
            Icons.help_outline,
            onTap: () {
              // Navigate to help
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & support coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildOptionTile(
            'Sign Out',
            Icons.logout,
            textColor: Colors.red,
            onTap: () {
              // Implement sign out functionality
              _showSignOutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon,
      {Color? textColor, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: const Text(
              'SIGN OUT',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
