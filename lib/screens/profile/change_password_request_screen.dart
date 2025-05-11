import 'package:flutter/material.dart';
import 'package:ghodacare/screens/profile/change_password_verify_screen.dart'; // Import next screen

class ChangePasswordRequestScreen extends StatefulWidget {
  const ChangePasswordRequestScreen({super.key});

  @override
  State<ChangePasswordRequestScreen> createState() =>
      _ChangePasswordRequestScreenState();
}

class _ChangePasswordRequestScreenState
    extends State<ChangePasswordRequestScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // TODO: Pre-fill with user's email if available
    _emailController.text = 'sarah.roe@email.com';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    // Basic validation
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email.'; // TODO: Localize
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Implement API call to send verification code
    print('Sending verification code to: ${_emailController.text}');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    setState(() {
      _isLoading = false;
    });

    // Navigate to verification screen on success (placeholder)
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChangePasswordVerifyScreen(email: _emailController.text)),
    );
    // Handle potential errors from API call here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'), // TODO: Localize
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address to receive a verification code.', // TODO: Localize
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email', // TODO: Localize
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.emailAddress,
              readOnly: true, // Assuming email is pre-filled and not editable
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendVerificationCode,
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
                    : const Text('Send Code'), // TODO: Localize
              ),
            ),
          ],
        ),
      ),
    );
  }
}
