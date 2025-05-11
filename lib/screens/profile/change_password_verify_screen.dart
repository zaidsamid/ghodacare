import 'package:flutter/material.dart';
import 'package:ghodacare/screens/profile/change_password_set_screen.dart'; // Import next screen

class ChangePasswordVerifyScreen extends StatefulWidget {
  final String email; // Email passed from previous screen
  const ChangePasswordVerifyScreen({super.key, required this.email});

  @override
  State<ChangePasswordVerifyScreen> createState() =>
      _ChangePasswordVerifyScreenState();
}

class _ChangePasswordVerifyScreenState
    extends State<ChangePasswordVerifyScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty || _codeController.text.length < 6) {
      // Assuming 6-digit code
      setState(() {
        _errorMessage = 'Please enter the 6-digit code.'; // TODO: Localize
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Implement API call to verify code
    print('Verifying code: ${_codeController.text} for email: ${widget.email}');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    bool isCodeValid = true; // Placeholder for API response

    setState(() {
      _isLoading = false;
    });

    if (isCodeValid) {
      // Navigate to set new password screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChangePasswordSetScreen(
                email: widget.email, verificationCode: _codeController.text)),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid verification code.'; // TODO: Localize
      });
    }
  }

  void _resendCode() {
    // TODO: Implement API call to resend verification code
    print('Resending code to: ${widget.email}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification code resent (Placeholder)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'), // TODO: Localize
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the verification code sent to ${widget.email}.', // TODO: Localize
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Verification Code', // TODO: Localize
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6, // Assuming 6-digit code
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _resendCode,
                child: const Text('Resend Code'), // TODO: Localize
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
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
                    : const Text('Verify'), // TODO: Localize
              ),
            ),
          ],
        ),
      ),
    );
  }
}
