import 'package:flutter/material.dart';

class ChangePasswordSetScreen extends StatefulWidget {
  final String email;
  final String verificationCode;
  const ChangePasswordSetScreen(
      {super.key, required this.email, required this.verificationCode});

  @override
  State<ChangePasswordSetScreen> createState() =>
      _ChangePasswordSetScreenState();
}

class _ChangePasswordSetScreenState extends State<ChangePasswordSetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _setNewPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Implement API call to set new password
    print(
        'Setting new password for: ${widget.email} with code: ${widget.verificationCode}');
    print('New Password: ${_newPasswordController.text}');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    bool success = true; // Placeholder for API response

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully!')),
      );
      // Pop back multiple times to profile tab (or use pushAndRemoveUntil)
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    } else {
      setState(() {
        _errorMessage =
            'Failed to change password. Please try again.'; // TODO: Localize
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set New Password'), // TODO: Localize
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your new password below.', // TODO: Localize
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password', // TODO: Localize
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword),
                  ),
                ),
                obscureText: _obscureNewPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password'; // TODO: Localize
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters'; // TODO: Localize
                  }
                  // TODO: Add more password complexity rules if needed
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password', // TODO: Localize
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password'; // TODO: Localize
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match'; // TODO: Localize
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14)),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _setNewPassword,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Set Password'), // TODO: Localize
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
