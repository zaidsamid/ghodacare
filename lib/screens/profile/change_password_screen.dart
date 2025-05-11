import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/language_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final languageProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.get('passwordChanged')),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.get('changePassword')),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSecurityIcon(),
                const SizedBox(height: 24),
                _buildPasswordFields(languageProvider),
                const SizedBox(height: 32),
                _buildSaveButton(languageProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_outline,
          size: 50,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildPasswordFields(LanguageProvider languageProvider) {
    return Column(
      children: [
        _buildPasswordField(
          controller: _currentPasswordController,
          labelText: languageProvider.get('currentPassword'),
          obscureText: _obscureCurrentPassword,
          onToggleObscure: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return languageProvider.get('requiredField');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _newPasswordController,
          labelText: languageProvider.get('newPassword'),
          obscureText: _obscureNewPassword,
          onToggleObscure: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return languageProvider.get('requiredField');
            }
            if (value.length < 8) {
              return languageProvider.get('passwordLength');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          controller: _confirmPasswordController,
          labelText: languageProvider.get('confirmPassword'),
          obscureText: _obscureConfirmPassword,
          onToggleObscure: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return languageProvider.get('requiredField');
            }
            if (value != _newPasswordController.text) {
              return languageProvider.get('passwordMismatch');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: onToggleObscure,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildSaveButton(LanguageProvider languageProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                languageProvider.get('save'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
