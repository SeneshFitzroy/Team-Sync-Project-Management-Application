import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Check if email is registered in Firebase
  Future<bool> _isEmailRegistered(String email) async {
    try {
      // Method 1: Check Firestore users collection
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        print('✅ Email found in Firestore: $email');
        return true;
      }

      // Method 2: Check Firebase Auth sign-in methods
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email.trim());
      if (signInMethods.isNotEmpty) {
        print('✅ Email found in Firebase Auth: $email');
        return true;
      }

      print('❌ Email not registered: $email');
      return false;
    } catch (e) {
      print('Error checking email: $e');
      // If there's an error checking, assume email exists to let Firebase handle it
      return true;
    }
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();
      
      // First verify if email is registered
      final isRegistered = await _isEmailRegistered(email);
      
      if (!isRegistered) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ This email is not registered with TaskSync.\nPlease check your email or create a new account.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Send Firebase password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Password reset email sent to $email\n\nPlease check your inbox and click the reset link.',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '❌ No account found with this email address.\nPlease check your email or create a new account.';
          break;
        case 'invalid-email':
          errorMessage = '❌ Please enter a valid email address.';
          break;
        case 'too-many-requests':
          errorMessage = '⏱️ Too many reset attempts.\nPlease wait a few minutes before trying again.';
          break;
        case 'user-disabled':
          errorMessage = '❌ This account has been disabled.\nPlease contact support for assistance.';
          break;
        default:
          errorMessage = '❌ Error sending reset email: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Unexpected error occurred: ${e.toString()}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reset Password',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Logo
                const Center(
                  child: TickLogo(
                    size: 100,
                    color: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.backgroundLight,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                Text(
                  _emailSent ? 'Check Your Email' : 'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  _emailSent 
                    ? 'We\'ve sent password reset instructions to your email. Please check your inbox and click the reset link.'
                    : 'Enter your registered email address and we\'ll send you a secure link to reset your password.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                if (!_emailSent) ...[
                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    style: AppTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Registered Email Address',
                      hintText: 'Enter your account email',
                      prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                      helperText: 'We\'ll verify this email is registered before sending reset link',
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Send Reset Email Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: AppTheme.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Verifying Email...', style: AppTheme.buttonText),
                            ],
                          )
                        : const Text(
                            'Send Password Reset Email',
                            style: AppTheme.buttonText,
                          ),
                    ),
                  ),
                ],
                
                if (_emailSent) ...[
                  // Success Animation or Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.mark_email_read,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Email sent confirmation
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'Reset Email Sent!',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check your email inbox and click the reset link to create a new password.',
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Resend Button
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    icon: const Icon(Icons.refresh, color: AppTheme.primaryBlue),
                    label: Text(
                      'Didn\'t receive email? Send again',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Back to Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Login',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Instructions Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Password Reset Process',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. We\'ll verify your email is registered\n'
                        '2. You\'ll receive a secure reset link\n'
                        '3. Click the link to set a new password\n'
                        '4. Login with your new credentials',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '💡 Tip: Check your spam folder if you don\'t see the email',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryBlue,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
