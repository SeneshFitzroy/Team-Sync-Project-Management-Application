import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/TickLogo.dart';
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

class _CreateAccountState extends State<CreateAccount> {
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

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Professional password strength checker
  void _updatePasswordStrength() {
    String password = _passwordController.text;
    int score = 0;
    List<String> criteria = [];
    
    if (password.length >= 8) {
      score++;
      criteria.add('✓ At least 8 characters');
    } else {
      criteria.add('✗ At least 8 characters');
    }
    
    if (password.contains(RegExp(r'[A-Z]'))) {
      score++;
      criteria.add('✓ Uppercase letter');
    } else {
      criteria.add('✗ Uppercase letter');
    }
    
    if (password.contains(RegExp(r'[a-z]'))) {
      score++;
      criteria.add('✓ Lowercase letter');
    } else {
      criteria.add('✗ Lowercase letter');
    }
    
    if (password.contains(RegExp(r'[0-9]'))) {
      score++;
      criteria.add('✓ Number');
    } else {
      criteria.add('✗ Number');
    }
    
    if (password.contains(RegExp(r'[@$!%*?&]'))) {
      score++;
      criteria.add('✓ Special character (@\$!%*?&)');
    } else {
      criteria.add('✗ Special character (@\$!%*?&)');
    }

    setState(() {
      _passwordStrength = score / 5.0;
      _passwordCriteria = criteria;
      
      switch (score) {
        case 0:
        case 1:
          _passwordStrengthText = 'Very Weak';
          _passwordStrengthColor = AppTheme.error;
          break;
        case 2:
          _passwordStrengthText = 'Weak';
          _passwordStrengthColor = Colors.orange;
          break;
        case 3:
          _passwordStrengthText = 'Fair';
          _passwordStrengthColor = Colors.yellow.shade700;
          break;
        case 4:
          _passwordStrengthText = 'Good';
          _passwordStrengthColor = Colors.lightGreen;
          break;
        case 5:
          _passwordStrengthText = 'Strong';
          _passwordStrengthColor = AppTheme.success;
          break;
      }
    });
  }

  bool _isPasswordValid() {
    String password = _passwordController.text;
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]')) &&
           password.contains(RegExp(r'[@$!%*?&]'));
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'First name can only contain letters';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Last name can only contain letters';
    }
    return null;
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces, dashes, and parentheses
    String cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Remove any leading zeros or + signs
    cleaned = cleaned.replaceFirst(RegExp(r'^[+0]+'), '');
    
    // Validate using country-specific rules
    if (!CountryCodeService.isValidPhoneNumber(cleaned, _selectedCountry)) {
      return 'Phone number must be ${_selectedCountry.minLength}-${_selectedCountry.maxLength} digits for ${_selectedCountry.name}';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    List<String> errors = [];
    
    // Check minimum length
    if (value.length < 8) {
      errors.add('• At least 8 characters');
    }
    
    // Check for uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add('• At least one uppercase letter (A-Z)');
    }
    
    // Check for lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      errors.add('• At least one lowercase letter (a-z)');
    }
    
    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      errors.add('• At least one number (0-9)');
    }
    
    // Check for special character
    if (!RegExp(r'[@$!%*?&]').hasMatch(value)) {
      errors.add('• At least one special character (@\$!%*?&)');
    }
    
    if (errors.isNotEmpty) {
      return 'Password must contain:\n${errors.join('\n')}';
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

    // Additional check for password strength
    if (!_isPasswordValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password does not meet all security requirements'),
          backgroundColor: AppTheme.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Debug: Check email service configuration
    EmailService.debugConfiguration();

    try {
      // Format phone number with country code
      String formattedPhoneNumber = CountryCodeService.formatPhoneNumber(
        _phoneController.text.trim(), 
        _selectedCountry
      );

      // Create user with Firebase Auth
      final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential.user != null) {
        // Update user display name
        String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
        await credential.user!.updateDisplayName(fullName);
        
        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'fullName': fullName,
          'email': _emailController.text.trim(),
          'phone': formattedPhoneNumber,
          'phoneCountry': _selectedCountry.name,
          'phoneCountryCode': _selectedCountry.dialCode,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'role': 'user',
          'profileCompleted': true,
          'emailVerified': false,
        });

        // Send Firebase email verification
        await credential.user!.sendEmailVerification();

        // Send WhatsApp welcome message (await to ensure it completes)
        bool whatsappSent = false;
        try {
          whatsappSent = await WhatsAppService.sendWelcomeMessage(
            phoneNumber: formattedPhoneNumber,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
          print('📱 WhatsApp message ${whatsappSent ? "sent" : "failed"}');
        } catch (e) {
          print('📱 WhatsApp error: $e');
        }

        // Send Email welcome message (await to ensure it completes)
        bool emailSent = false;
        try {
          emailSent = await EmailService.sendWelcomeEmail(
            toEmail: _emailController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: formattedPhoneNumber,
          );
          print('📧 Welcome email ${emailSent ? "sent successfully" : "failed"} to ${_emailController.text.trim()}');
        } catch (e) {
          print('📧 Email service error: $e');
        }

        if (mounted) {
          // Navigate directly to dashboard without any persistent messages
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainAppNavigator(),
            ),
            (route) => false, // Clear all previous routes
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred while creating your account';
      
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email. Please sign in instead.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = 'Failed to create account: ${e.message}';
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
            content: Text('Account creation failed: ${e.toString()}'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: TickLogo(
                    size: 80,
                    color: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.backgroundLight,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Join TaskSync and start managing your projects',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // First Name field
                TextFormField(
                  controller: _firstNameController,
                  validator: _validateFirstName,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outlined, color: AppTheme.textSecondary),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Last Name field
                TextFormField(
                  controller: _lastNameController,
                  validator: _validateLastName,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outlined, color: AppTheme.textSecondary),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Phone field with country code
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Country Code Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CountryCode>(
                              value: _selectedCountry,
                              onChanged: (CountryCode? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCountry = newValue;
                                  });
                                }
                              },
                              items: CountryCodeService.countries.map<DropdownMenuItem<CountryCode>>((CountryCode country) {
                                return DropdownMenuItem<CountryCode>(
                                  value: country,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(country.flag, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(
                                        country.dialCode,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Phone Number Input
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                            style: AppTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: _selectedCountry.name == 'Sri Lanka' 
                                  ? '77 123 4567' 
                                  : 'Enter phone number',
                              prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                              helperText: 'Length: ${_selectedCountry.minLength}-${_selectedCountry.maxLength} digits',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  style: AppTheme.bodyLarge,
                  onChanged: (value) {
                    // Trigger real-time validation and password strength calculation
                    _updatePasswordStrength();
                    _formKey.currentState?.validate();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: 'Min 8 chars, uppercase, lowercase, number, special char (@\$!%*?&)',
                    helperMaxLines: 2,
                    prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                
                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: AppTheme.backgroundLight,
                          valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _passwordStrengthText,
                        style: AppTheme.bodySmall.copyWith(
                          color: _passwordStrengthColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Password criteria checklist
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _passwordCriteria.map((criterion) {
                      bool isMet = criterion.startsWith('✓');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 16,
                              color: isMet ? AppTheme.success : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              criterion.substring(2), // Remove ✓ or ✗
                              style: AppTheme.bodySmall.copyWith(
                                color: isMet ? AppTheme.success : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  style: AppTheme.bodyLarge,
                  onChanged: (value) {
                    // Trigger real-time validation for password confirmation
                    _formKey.currentState?.validate();
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    helperText: 'Re-enter your password to confirm',
                    prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Create Account button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppTheme.backgroundLight,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: AppTheme.buttonText,
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Login link
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
                      onPressed: _isLoading ? null : () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryBlue,
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
    );
  }
}
