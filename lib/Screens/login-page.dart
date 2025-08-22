import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';
import '../Screens/MainAppNavigator.dart';
import 'create_account_new.dart';
import 'ForgetPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted && credential.user != null) {
        // Update last login timestamp in Firestore
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Continue with login even if Firestore update fails
          print('Failed to update last login: $e');
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainAppNavigator()),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Welcome back! Login successful.'),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred while signing in';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email address.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password. Please check your credentials.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred during login'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 3),
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

  // Navigate to Forgot Password page
  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgetPasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo
              const Center(
                child: TickLogo(size: 120),
              ),
              
              const SizedBox(height: 48),
              
              // Welcome Text
              Text(
                'Welcome Back',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Sign in to your account',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to forgot password page when available
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot password feature coming soon')),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Sign In Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textWhite),
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: AppTheme.buttonText,
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateAccount()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
