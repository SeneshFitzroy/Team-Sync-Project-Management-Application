import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Services/auth_service.dart';
import '../Services/whatsapp_service.dart';
import '../Services/email_service.dart';
import '../Services/country_code_service.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';
import 'MainAppNavigator.dart';
import 'login-page.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _particleAnimationController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  CountryCode _selectedCountry = CountryCodeService.getDefaultCountry();
  
  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;
  List<Map<String, dynamic>> _passwordCriteria = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _passwordController.addListener(_validatePasswordStrength);
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswordStrength() {
    String password = _passwordController.text;
    
    setState(() {
      // Calculate password strength
      int score = 0;
      List<Map<String, dynamic>> criteria = [
        {'text': 'At least 8 characters', 'met': password.length >= 8},
        {'text': 'Contains uppercase letter', 'met': password.contains(RegExp(r'[A-Z]'))},
        {'text': 'Contains lowercase letter', 'met': password.contains(RegExp(r'[a-z]'))},
        {'text': 'Contains number', 'met': password.contains(RegExp(r'[0-9]'))},
        {'text': 'Contains special character', 'met': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))},
      ];

      for (var criterion in criteria) {
        if (criterion['met']) score++;
      }

      _passwordStrength = score / 5.0;
      _passwordCriteria = criteria;

      // Set strength text and color
      if (score <= 1) {
        _passwordStrengthText = 'Very Weak';
        _passwordStrengthColor = AppTheme.error;
      } else if (score == 2) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.orange;
      } else if (score == 3) {
        _passwordStrengthText = 'Fair';
        _passwordStrengthColor = Colors.yellow.shade700;
      } else if (score == 4) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = Colors.lightGreen;
      } else {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = AppTheme.success;
      }
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (!CountryCodeService.isValidPhoneNumber(cleaned, _selectedCountry)) {
      return 'Phone number must be ${_selectedCountry.minLength}-${_selectedCountry.maxLength} digits for ${_selectedCountry.name}';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    // Check password strength
    if (_passwordStrength < 0.6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please choose a stronger password'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Starting account creation process...');

      // Create Firebase Auth account
      UserCredential? result = await AuthService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        phoneNumber: _phoneController.text.trim(),
      );

      if (result != null && result.user != null) {
        String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
        
        print('✅ Firebase Auth account created successfully');

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'fullName': fullName,
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'phoneCountry': _selectedCountry.name,
          'phoneCountryCode': _selectedCountry.dialCode,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ User data saved to Firestore');

        // Send WhatsApp welcome message
        try {
          bool whatsAppSent = await WhatsAppService.sendWelcomeMessage(
            phoneNumber: _phoneController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
          print('📱 WhatsApp welcome ${whatsAppSent ? "sent successfully" : "failed"}');
        } catch (e) {
          print('📱 WhatsApp service error: $e');
        }

        // Send welcome email
        try {
          bool emailSent = await EmailService.sendWelcomeEmail(
            toEmail: _emailController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );
          print('📧 Welcome email ${emailSent ? "sent successfully" : "failed"} to ${_emailController.text.trim()}');
        } catch (e) {
          print('📧 Email service error: $e');
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainAppNavigator()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth Error: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      print('❌ General Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        
                        // Animated logo and title
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              TickLogo(size: 80),
                              SizedBox(height: 24),
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Join us and start managing your projects',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 40),
                        
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
                              child: Column(
                                children: [
                                  // First Name Field
                                  _buildTextField(
                                    controller: _firstNameController,
                                    label: 'First Name',
                                    icon: Icons.person_outline,
                                    validator: _validateName,
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Last Name Field
                                  _buildTextField(
                                    controller: _lastNameController,
                                    label: 'Last Name',
                                    icon: Icons.person_outline,
                                    validator: _validateName,
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Email Field
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    validator: _validateEmail,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Country and Phone Row
                                  Row(
                                    children: [
                                      // Country Dropdown
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(12),
                                            color: Colors.grey.shade50,
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<CountryCode>(
                                              value: _selectedCountry,
                                              isExpanded: true,
                                              icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
                                              onChanged: (CountryCode? newValue) {
                                                setState(() {
                                                  _selectedCountry = newValue!;
                                                });
                                              },
                                              items: CountryCodeService.countries.map<DropdownMenuItem<CountryCode>>((CountryCode country) {
                                                return DropdownMenuItem<CountryCode>(
                                                  value: country,
                                                  child: Row(
                                                    children: [
                                                      Text(country.flag, style: TextStyle(fontSize: 20)),
                                                      SizedBox(width: 8),
                                                      Text(country.dialCode, style: TextStyle(fontWeight: FontWeight.w500)),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      SizedBox(width: 12),
                                      
                                      // Phone Number Field
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          controller: _phoneController,
                                          decoration: InputDecoration(
                                            labelText: 'Phone Number',
                                            hintText: _selectedCountry.name == 'Sri Lanka' 
                                                ? '761234567' 
                                                : 'Enter phone number',
                                            helperText: 'Length: ${_selectedCountry.minLength}-${_selectedCountry.maxLength} digits',
                                            prefixIcon: Container(
                                              margin: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.phone_outlined, color: Colors.white),
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
                                          keyboardType: TextInputType.phone,
                                          validator: _validatePhone,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 16),
                                  
                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Container(
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.lock_outline, color: Colors.white),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: AppTheme.primaryBlue,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
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
                                    validator: _validatePassword,
                                    onChanged: (value) {
                                      _formKey.currentState?.validate();
                                    },
                                  ),
                                  
                                  // Password strength indicator
                                  if (_passwordController.text.isNotEmpty) ...[
                                    SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: _passwordStrength,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _passwordStrengthText,
                                          style: TextStyle(
                                            color: _passwordStrengthColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Column(
                                      children: _passwordCriteria.map((criterion) {
                                        return Row(
                                          children: [
                                            Icon(
                                              criterion['met'] ? Icons.check_circle : Icons.radio_button_unchecked,
                                              color: criterion['met'] ? AppTheme.success : Colors.grey,
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              criterion['text'],
                                              style: TextStyle(
                                                color: criterion['met'] ? AppTheme.success : Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  
                                  SizedBox(height: 16),
                                  
                                  // Confirm Password Field
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      prefixIcon: Container(
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.lock_outline, color: Colors.white),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: AppTheme.primaryBlue,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                        },
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
                                    validator: _validateConfirmPassword,
                                    onChanged: (value) {
                                      _formKey.currentState?.validate();
                                    },
                                  ),
                                  
                                  SizedBox(height: 24),
                                  
                                  // Create Account Button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleCreateAccount,
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
                                                  'Create Account',
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
                                  
                                  // Login link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                      GestureDetector(
                                        onTap: _isLoading ? null : () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => LoginPage()),
                                          );
                                        },
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
                            ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        suffixIcon: suffixIcon,
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
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
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
