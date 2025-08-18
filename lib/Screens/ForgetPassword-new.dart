import 'package:flutter/material.dart';
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

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate sending reset email
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: AppTheme.success,
          ),
        );
        
        // Go back to login
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: ${e.toString()}'),
            backgroundColor: AppTheme.error,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Logo
                const Center(
                  child: TickLogo(
                    size: 100,
                    color: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.backgroundLight,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                Text(
                  'Forgot Password?',
                  textAlign: TextAlign.center,
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  style: AppTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Send Reset Email button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textWhite),
                          )
                        : const Text(
                            'Send Reset Email',
                            style: AppTheme.buttonText,
                          ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Back to login link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to Login',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
