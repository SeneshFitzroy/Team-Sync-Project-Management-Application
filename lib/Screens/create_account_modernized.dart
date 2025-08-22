import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ConsistentHeader.dart';
import '../theme/app_theme.dart';
import '../Screens/MainAppNavigator.dart';
import '../services/whatsapp_service.dart';
import '../services/email_service.dart';
import '../services/country_code_service.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});
  
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  // Country code selection
  CountryCode _selectedCountry = CountryCodeService.getDefaultCountry();
  
  // Professional password strength tracking
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = AppTheme.textSecondary;
  List<String> _passwordCriteria = [];

  late AnimationController _particleController;
  late AnimationController _formController;
  late Animation<double> _particleAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() async {
    _particleController.repeat();
    await Future.delayed(const Duration(milliseconds: 500));
    _formController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _particleController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    String password = _passwordController.text;
    double strength = 0.0;
    List<String> criteria = [];
    
    if (password.length >= 8) {
      strength += 0.2;
      criteria.add('✓ At least 8 characters');
    } else {
      criteria.add('✗ At least 8 characters');
    }
    
    if (password.contains(RegExp(r'[A-Z]'))) {
      strength += 0.2;
      criteria.add('✓ Uppercase letter');
    } else {
      criteria.add('✗ Uppercase letter');
    }
    
    if (password.contains(RegExp(r'[a-z]'))) {
      strength += 0.2;
      criteria.add('✓ Lowercase letter');
    } else {
      criteria.add('✗ Lowercase letter');
    }
    
    if (password.contains(RegExp(r'[0-9]'))) {
      strength += 0.2;
      criteria.add('✓ Number');
    } else {
      criteria.add('✗ Number');
    }
    
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength += 0.2;
      criteria.add('✓ Special character');
    } else {
      criteria.add('✗ Special character');
    }
    
    setState(() {
      _passwordStrength = strength;
      _passwordCriteria = criteria;
      
      if (strength < 0.4) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.8) {
        _passwordStrengthText = 'Medium';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    if (_passwordStrength < 0.6) {
      _showErrorSnackBar('Please create a stronger password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      
      // Create user account
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential.user != null) {
        // Update user profile
        await credential.user!.updateDisplayName(
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
        );

        // Store user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': '${_selectedCountry.dialCode}${_phoneController.text.trim()}',
          'countryCode': _selectedCountry.code,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        // Send WhatsApp message
        try {
          final whatsappService = WhatsAppService();
          final phoneNumber = '${_selectedCountry.dialCode}${_phoneController.text.trim()}';
          await whatsappService.sendWelcomeMessage(
            phoneNumber: phoneNumber,
            userName: _firstNameController.text.trim(),
          );
        } catch (e) {
          print('WhatsApp service error: $e');
        }

        // Send welcome email
        try {
          final emailService = EmailService();
          await emailService.sendWelcomeEmail(
            toEmail: _emailController.text.trim(),
            userName: _firstNameController.text.trim(),
          );
        } catch (e) {
          print('Email service error: $e');
        }

        if (mounted) {
          HapticFeedback.heavyImpact();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MainAppNavigator(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Account creation failed';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Colors.white,
              Color(0xFFF1F5F9),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background particles (consistent design)
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CreateAccountParticlePainter(_particleAnimation.value),
                    size: MediaQuery.of(context).size,
                  );
                },
              ),
              
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Consistent Header with blue-purple gradient ball tick
                      const ConsistentHeader(
                        title: 'Create Account',
                        subtitle: 'Join TaskSync and boost your productivity',
                        logoSize: 100,
                        showDecorative: false,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Animated Form
                      FadeTransition(
                        opacity: _formAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name Fields Row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _firstNameController,
                                    label: 'First Name',
                                    prefixIcon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: _lastNameController,
                                    label: 'Last Name',
                                    prefixIcon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Email Field
                            _buildModernTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Phone Field with Country Code
                            _buildPhoneField(),
                            
                            const SizedBox(height: 20),
                            
                            // Password Field
                            _buildModernTextField(
                              controller: _passwordController,
                              label: 'Password',
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (_passwordStrength < 0.6) {
                                  return 'Password is too weak';
                                }
                                return null;
                              },
                            ),
                            
                            // Password Strength Indicator
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildPasswordStrengthIndicator(),
                            ],
                            
                            const SizedBox(height: 20),
                            
                            // Confirm Password Field
                            _buildModernTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
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
                            
                            const SizedBox(height: 40),
                            
                            // Create Account Button
                            _buildModernButton(
                              text: 'Create Account',
                              onPressed: _isLoading ? null : _createAccount,
                              isLoading: _isLoading,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          AppTheme.primaryBlue,
                                          Color(0xFF764BA2),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      'Sign In',
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? (label.contains('Confirm') ? _obscureConfirmPassword : _obscurePassword) : false,
        validator: validator,
        style: AppTheme.bodyLarge.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.primaryBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 2,
            ),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppTheme.textSecondary)
              : null,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: AppTheme.bodyLarge.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Phone number is required';
          }
          if (value.trim().length < 8) {
            return 'Enter a valid phone number';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.primaryBlue,
              width: 2,
            ),
          ),
          prefixIcon: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CountryCode>(
                value: _selectedCountry,
                items: CountryCodeService.getAllCountries().map((country) {
                  return DropdownMenuItem<CountryCode>(
                    value: country,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          country.flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          country.dialCode,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (CountryCode? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCountry = newValue;
                    });
                  }
                },
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Strength',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                _passwordStrengthText,
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _passwordStrengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: AppTheme.backgroundLight,
            valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _passwordCriteria.map((criterion) {
              bool isValid = criterion.startsWith('✓');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  criterion,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: 11,
                    color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: AppTheme.bodyLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for create account page particles (consistent design)
class CreateAccountParticlePainter extends CustomPainter {
  final double animationValue;
  
  CreateAccountParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Generate consistent particles based on screen size
    final random = Random(24); // Different seed for create account
    
    for (int i = 0; i < 10; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + (random.nextDouble() * 2.0);
      
      // Animate opacity and position
      final opacity = (0.04 + (random.nextDouble() * 0.15)) * 
                     (0.5 + 0.5 * sin(animationValue * 2 * pi + i));
      final offsetY = sin(animationValue * 2 * pi + i * 0.5) * 6;
      
      paint.color = AppTheme.primaryBlue.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y + offsetY),
        radius,
        paint,
      );
    }
    
    // Add some larger, slower moving particles
    for (int i = 0; i < 4; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.5 + (random.nextDouble() * 2.5);
      
      final opacity = (0.02 + (random.nextDouble() * 0.08)) * 
                     (0.3 + 0.7 * sin(animationValue * pi + i * 0.3));
      final offsetY = cos(animationValue * pi + i * 0.7) * 10;
      final offsetX = sin(animationValue * 0.5 * pi + i * 0.4) * 3;
      
      paint.color = const Color(0xFF764BA2).withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
