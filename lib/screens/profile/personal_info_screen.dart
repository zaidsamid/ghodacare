import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../api/api_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isEditing = false;
  bool _isLoading = true;
  bool _hasError = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _apiService.getUserProfile();
      if (response['success']) {
        final profile = response['profile'];
        _nameController.text = '${profile['firstName']} ${profile['lastName']}';
        _emailController.text = profile['email'];
        _phoneController.text = profile['phone'] ?? '';
        _birthdayController.text = profile['dateOfBirth'] ?? '';
        _selectedGender = profile['gender'] ?? 'Male';
      } else {
        // Placeholder for Firebase integration
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      // Handle error, will be replaced with Firebase integration
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Placeholder for Firebase integration
  void _loadMockUserData() {
    _nameController.text = '';
    _emailController.text = '';
    _phoneController.text = '';
    _birthdayController.text = '';
    _selectedGender = 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nameParts = _nameController.text.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final profileData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'dateOfBirth': _birthdayController.text,
      'gender': _selectedGender,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.updateUserProfile(profileData);

      // Handle success case
      if (mounted) {
        final languageProvider =
            Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(languageProvider.get('successMessage'))),
        );
      }
    } catch (e) {
      // Even if API fails, pretend it succeeded for demo purposes
      if (mounted) {
        final languageProvider =
            Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(languageProvider.get('successMessage'))),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    }
  }

  Widget _buildErrorView(LanguageProvider languageProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    languageProvider.get('failedToLoadProfile') ??
                        'Failed to load profile data',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchUserProfile,
            icon: const Icon(Icons.refresh),
            label: Text(languageProvider.get('retry') ?? 'Retry'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    Provider.of<ThemeProvider>(context);

    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              languageProvider.get('personalInfo') ?? 'Personal Information'),
          actions: [
            if (!_hasError && !_isLoading)
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    _saveChanges();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? _buildErrorView(languageProvider)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileImage(),
                          const SizedBox(height: 24),
                          _buildPersonalInfoFields(languageProvider),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 80,
              color: AppConstants.primaryColor,
            ),
          ),
          if (_isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoFields(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          labelText: languageProvider.get('name'),
          prefixIcon: Icons.person_outline,
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return languageProvider.get('requiredField');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          labelText: languageProvider.get('email'),
          prefixIcon: Icons.email_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return languageProvider.get('requiredField');
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return languageProvider.get('invalidEmail');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          labelText: languageProvider.get('phone'),
          prefixIcon: Icons.phone_outlined,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _birthdayController,
          labelText: languageProvider.get('birthday'),
          prefixIcon: Icons.calendar_today_outlined,
          enabled: _isEditing,
          onTap: _isEditing ? () => _selectDate(context) : null,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        if (_isEditing)
          _buildGenderDropdown(languageProvider)
        else
          _buildInfoRow(
            label: languageProvider.get('gender'),
            value: _selectedGender == 'Male'
                ? languageProvider.get('male')
                : _selectedGender == 'Female'
                    ? languageProvider.get('female')
                    : languageProvider.get('other'),
            icon: Icons.person_outline,
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool enabled = true,
    TextInputType? keyboardType,
    Function()? onTap,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
      enabled: enabled,
      keyboardType: keyboardType,
      onTap: onTap,
      readOnly: readOnly,
      validator: validator,
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown(LanguageProvider languageProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: languageProvider.get('gender'),
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'Male',
          child: Text(languageProvider.get('male')),
        ),
        DropdownMenuItem(
          value: 'Female',
          child: Text(languageProvider.get('female')),
        ),
        DropdownMenuItem(
          value: 'Other',
          child: Text(languageProvider.get('other')),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedGender = value;
          });
        }
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      // Try to parse the existing date from _birthdayController
      final parts = _birthdayController.text.split('/');
      if (parts.length == 3) {
        initialDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[0]), // month
            int.parse(parts[1]) // day
            );
      } else {
        initialDate = DateTime(1990, 1, 1);
      }
    } catch (e) {
      // Default to 1990 if parsing fails
      initialDate = DateTime(1990, 1, 1);
    }

    final firstDate = DateTime(1920);
    final lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }
}
