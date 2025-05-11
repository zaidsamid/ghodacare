// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ghodacare/constants/app_constants.dart';
import 'package:ghodacare/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ghodacare/providers/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  DateTime? _selectedDate;
  String? _avatarUrl;

  bool _isLoading = true; // Start in loading state
  bool _isSuccess = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize controllers empty, they will be populated by _loadUserData
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData(); // Load data immediately
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return; // Check if widget is still mounted
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _apiService.getUserProfile();

      if (!mounted) return;

      // Check for success and presence of data
      if (response['success'] == true && response['data'] != null) {
        final userData =
            response['data'] as Map<String, dynamic>; // Cast for safety

        setState(() {
          // Load data safely using null checks
          _nameController.text = userData['name']?.toString() ?? '';
          _emailController.text = userData['email']?.toString() ?? '';
          _phoneController.text = userData['phone_number']?.toString() ?? '';
          _selectedGender = userData['gender']?.toString(); // Can be null
          _avatarUrl = userData['avatar_url']?.toString(); // Can be null

          // Safely parse date
          final dobString = userData['birth_date']?.toString();
          if (dobString != null && dobString.isNotEmpty) {
            try {
              _selectedDate = DateTime.parse(dobString);
            } catch (e) {
              _selectedDate = null;
            }
          } else {
            _selectedDate = null;
          }
        });
      } else {
        // Handle API error or missing data
        setState(() {
          _errorMessage =
              response['message']?.toString() ?? 'Failed to load profile data';
          // Set default/empty values if load fails
          _nameController.text = '';
          _emailController.text = '';
          _phoneController.text = '';
          _selectedGender = null;
          _selectedDate = null;
          _avatarUrl = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Handle general exceptions during API call
      setState(() {
        _errorMessage = 'Error loading profile: ${e.toString()}';
        _nameController.text = ''; // Reset fields on error
        _emailController.text = '';
        _phoneController.text = '';
        _selectedGender = null;
        _selectedDate = null;
        _avatarUrl = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Format date correctly for API
      final String? dobFormatted = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;

      final profileData = {
        'name': _nameController.text,
        'email': _emailController
            .text, // Assuming email might be updatable, adjust if not
        'phone_number': _phoneController.text,
        'birth_date': dobFormatted,
        'gender': _selectedGender,
        // 'avatar_url': _avatarUrl, // TODO: Handle avatar update separately if needed
      };

      final response = await _apiService.updateUserProfile(profileData);
      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _isSuccess = true;
        });

        // Navigate back after short delay, passing true to indicate success
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error updating profile: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton(
            onPressed: _updateProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileForm(),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
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
              const SizedBox(height: 24),
            ],

            if (_isSuccess) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Profile updated successfully!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 8),

            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    child: _avatarUrl == null
                        ? Icon(Icons.person,
                            size: 70, color: Colors.grey.shade600)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          // TODO: Implement avatar change logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Change avatar coming soon')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Full Name', Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Email', Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration:
                  _inputDecoration('Phone Number', Icons.phone_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration('Gender', Icons.wc_outlined),
              items: <String>['Female', 'Male', 'Other', 'Prefer not to say']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date of Birth field
            TextFormField(
              readOnly: true,
              decoration: _inputDecoration(
                  'Date of Birth', Icons.calendar_today_outlined),
              onTap: () => _selectDate(context),
              validator: (value) {
                return null;
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppConstants.primaryColor),
      ),
    );
  }
}
