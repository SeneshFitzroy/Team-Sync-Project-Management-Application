import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';
import 'create account.dart';
import 'ForgetPassword.dart';
import 'Dashboard.dart';

class LoginPage extends StatefulWidget {
  final String? initialEmail;

  const LoginPage({
    super.key, 
    this.initialEmail,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
    _checkAuthState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    // Check if user is already authenticated
    User? user = AuthService.currentUser;
    if (user != null) {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? userCredential = await AuthService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential != null && mounted) {
        _showSuccessSnackBar('Welcome back!');
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccount(),
      ),
    );
  }

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const TickLogo(
                      color: AppTheme.textWhite,
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Welcome Text
                    Text(
                      'Welcome Back!',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontSize: 32,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Sign in to your account',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.8),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: AppTheme.textWhite.withOpacity(0.8),
                          fontFamily: AppTheme.fontFamily,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppTheme.textWhite.withOpacity(0.8),
                        ),
                        filled: true,
                        fillColor: AppTheme.textWhite.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.textWhite.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.textWhite.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.textWhite,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.error,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: AppTheme.textWhite.withOpacity(0.8),
                          fontFamily: AppTheme.fontFamily,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppTheme.textWhite.withOpacity(0.8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textWhite.withOpacity(0.8),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppTheme.textWhite.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.textWhite.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.textWhite.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.textWhite,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.error,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              fillColor: MaterialStateProperty.all(
                                AppTheme.textWhite.withOpacity(0.8),
                              ),
                              checkColor: AppTheme.primaryBlue,
                            ),
                            Text(
                              'Remember me',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textWhite.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textWhite,
                          foregroundColor: AppTheme.primaryBlue,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: AppTheme.buttonText.copyWith(
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textWhite.withOpacity(0.8),
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToSignUp,
                          child: Text(
                            'Sign Up',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
