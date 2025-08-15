import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String email;
  const OTPVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Please check your email')),
      body: Center(
        child: Text('OTP Verification for $email - Under Construction'),
      ),
    );
  }
}
