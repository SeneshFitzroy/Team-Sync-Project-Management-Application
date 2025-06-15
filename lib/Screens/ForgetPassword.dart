import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'ForgetPassword2.dart'; // Moved to backup

// Static class to store verification codes and timestamps (keeping for compatibility)
class ForgetPassword {
  // Maps to store verification codes and timestamps by email
  static Map<String, String> verificationCodes = {};
  static Map<String, int> verificationTimestamps = {};
}

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Function to send password reset email
  Future<void> _sendPasswordResetEmail() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();

      // Send Firebase password reset email
      await _auth.sendPasswordResetEmail(email: email);

      if (mounted) {
        // Navigate to confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPassword2(
              email: email,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email address';
      } else if (e.code == 'network-request-failed' || 
                (e.message != null && e.message.toString().contains("network error"))) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many reset attempts. Please wait 15-30 minutes before trying again.';
      } else if (e.message != null && e.message.toString().contains("unusual activity")) {
        errorMessage = 'Request blocked due to unusual activity. Please try again later or contact support.';
      } else {
        errorMessage = 'Error: ${e.message}';
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
    } catch (e) {
      String errorMessage = 'Error: ${e.toString()}';
      
      // Check specifically for network errors in the general exception
      if (e.toString().contains('network error') || 
          e.toString().contains('timeout') || 
          e.toString().contains('connection') ||
          e.toString().contains('unreachable host')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFF0F8FF)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 39,
                      height: 39,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFD8DADC),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),

                  // Title
                  SizedBox(height: 55),
                  Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      height: 1.30,
                      letterSpacing: -0.30,
                    ),
                  ),

                  // Description - Updated to reflect email link flow
                  SizedBox(height: 20),
                  Text(
                    'Enter your email and we\'ll send you a link to reset your password.',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),

                  // Email input
                  SizedBox(height: 58),
                  Text(
                    'Email address',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    width: screenWidth - 40, // Full width minus padding
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFD8DADC),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),

                  // Send reset link button (renamed from Send code)
                  SizedBox(height: 62),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendPasswordResetEmail,
                    child: Container(
                      width: screenWidth - 40, // Full width minus padding
                      height: 56,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF192F5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ))
                            : const Text(
                                'Send Reset Link',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Spacer to push "Remember password" to bottom
                  Spacer(),

                  // Remember password
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Remember password? ',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                ),
                              ),
                              const TextSpan(
                                text: 'Log in',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
