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

class _ForgetPasswordPageState extends State<ForgetPasswordPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _particleAnimationController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _particleAnimationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutBack,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleAnimationController);

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _particleAnimationController.repeat();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _particleAnimationController.dispose();
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

  /// Enhanced password reset with proper Firebase Auth handling
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();
      print('🔄 Starting password reset process for: $email');

      // Send password reset email directly - Firebase Auth will handle validation
      print('📧 Sending password reset email...');
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://your-app-domain.com/reset-password',
          handleCodeInApp: false,
          androidInstallApp: false,
          androidMinimumVersion: '1.0.0',
        ),
      );

      print('✅ Password reset email sent successfully');

      // Update UI to show success
      setState(() {
        _emailSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password reset instructions have been sent to $email. Please check your inbox.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      String errorMessage = 'An error occurred while sending reset instructions.';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address. Please check your email or create a new account.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many reset attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'Failed to send reset instructions.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.error,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'An unexpected error occurred. Please try again.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.error,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
        ),
      );

      print('✅ Password reset email sent successfully');

      setState(() {
        _emailSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password reset email sent! Please check your inbox and spam folder.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth Error: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many password reset attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred while sending the reset email.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.error,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ General Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'An unexpected error occurred. Please try again.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.error,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particle background
            AnimatedBuilder(
              animation: _particleAnimation,
              child: Container(),
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      
                      // Back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 40),
                      
                      // Animated logo and title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            TickLogo(size: 80),
                            SizedBox(height: 24),
                            Text(
                              _emailSent ? 'Check Your Email' : 'Reset Password',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              _emailSent 
                                  ? 'We\'ve sent password reset instructions to your email'
                                  : 'Enter your email to receive reset instructions',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 60),
                      
                      // Animated form container
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: _emailSent ? _buildSuccessContent() : _buildFormContent(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your registered email',
              prefixIcon: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.email_outlined, color: Colors.white),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: _validateEmail,
          ),
          
          SizedBox(height: 24),
          
          // Reset password button
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Send Reset Instructions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Back to login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remember your password? ',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        SizedBox(height: 24),
        
        Text(
          'Reset Email Sent!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        
        SizedBox(height: 12),
        
        Text(
          'We\'ve sent password reset instructions to:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 8),
        
        Text(
          _emailController.text.trim(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
        ),
        
        SizedBox(height: 24),
        
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              SizedBox(height: 8),
              Text(
                'Check your spam folder if you don\'t see the email in your inbox.',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Resend button
        Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                _emailSent = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Send Another Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Back to login
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// Particle painter for background animation
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 50; i++) {
      final x = (i * 37.0 + animationValue * 50) % size.width;
      final y = (i * 43.0 + animationValue * 30) % size.height;
      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
