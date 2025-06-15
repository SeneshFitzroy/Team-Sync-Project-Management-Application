import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'login-page.dart';

class ForgotPassword2 extends StatefulWidget {
  final String email;
  final String? verificationCode; // Keeping for backward compatibility
  
  const ForgotPassword2({
    super.key,
    this.email = 'helloworld@gmail.com',
    this.verificationCode,
  });

  @override
  _ForgotPassword2State createState() => _ForgotPassword2State();
}

class _ForgotPassword2State extends State<ForgotPassword2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isResending = false;

  // Resend the password reset email
  Future<void> _resendResetEmail() async {
    if (_isResending) return;
    
    setState(() {
      _isResending = true;
    });
    
    try {
      await _auth.sendPasswordResetEmail(email: widget.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent again! Please check your email.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to resend link: ${e.toString()}';
      
      if (e is FirebaseAuthException) {
        if (e.code == 'too-many-requests') {
          errorMessage = 'Too many reset attempts. Please wait 15-30 minutes before trying again.';
        } else if (e.message != null && e.message.toString().contains("unusual activity")) {
          errorMessage = 'Request blocked due to unusual activity. Please try again later.';
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              
              // App logo or icon
              const Icon(
                Icons.email_outlined,
                size: 100,
                color: Color(0xFF192F5D),
              ),
              
              const SizedBox(height: 40),
              
              // Header text
              const Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 1.30,
                  letterSpacing: -0.30,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Message
              Text(
                'We\'ve sent a password reset link to ${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'Click the link in the email to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Email client suggestions
              const Text(
                "Can't find the email? Check your spam folder.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Resend button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isResending ? null : _resendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF192F5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isResending 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Resend Email',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Back to login button
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Color(0xFF192F5D),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
