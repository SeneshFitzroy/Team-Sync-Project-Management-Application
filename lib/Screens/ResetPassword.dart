import 'package:flutter/material.dart';
import 'PasswordChanged.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  bool _isLoading = false;

  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword() {
    if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters';
      });
      return false;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = 'Passwords do not match';
      });
      return false;
    }
    
    setState(() {
      _passwordError = null;
    });
    return true;
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
    } else if (password.length < 8) {
      setState(() {
        _passwordStrength = 'Weak';
        _passwordStrengthColor = Colors.red;
      });
    } else if (RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$').hasMatch(password)) {
      setState(() {
        _passwordStrength = 'Strong';
        _passwordStrengthColor = Colors.green;
      });
    } else {
      setState(() {
        _passwordStrength = 'Medium';
        _passwordStrengthColor = Colors.orange;
      });
    }
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate() && _validatePassword()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Replace with actual API call
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isLoading = false;
        });

        // Navigate to PasswordChanged screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordChanged(),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F8FF),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 39,
                      height: 39,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFD8DADC),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black54),
                    ),
                  ),
                  
                  const SizedBox(height: 65),
                  
                  // Title
                  const Text(
                    'Reset password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      height: 1.30,
                      letterSpacing: -0.30,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'Please type something you would like me to remember.',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 42),
                  
                  // New password field with strength indicator
                  const Text(
                    'New password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _checkPasswordStrength,
                    decoration: InputDecoration(
                      hintText: 'Must be at least 8 characters',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD8DADC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD8DADC)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Row(
                    children: [
                      Text(
                        'Password strength: $_passwordStrength',
                        style: TextStyle(
                          color: _passwordStrengthColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Confirm password field
                  const Text(
                    'Confirm new password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Repeat password',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD8DADC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD8DADC)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 42),
                  
                  // Reset button with loading spinner
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF192F5D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: const Color(0xFF192F5D).withOpacity(0.7),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Processing...'),
                              ],
                            )
                          : const Text(
                              'Reset password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 255),
                  
                  // Login link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
