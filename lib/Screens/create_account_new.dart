import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/TickLogo.dart';
import '../theme/app_theme.dart';
import '../Screens/MainAppNavigator.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
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
      criteria.add('✓ Special character (@$!%*?&)');
    } else {
      criteria.add('✗ Special character (@$!%*?&)');
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
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

  void _calculatePasswordStrength(String password) {
    int criteria = 0;
    
    if (password.length >= 8) criteria++;
    if (RegExp(r'[A-Z]').hasMatch(password)) criteria++;
    if (RegExp(r'[a-z]').hasMatch(password)) criteria++;
    if (RegExp(r'[0-9]').hasMatch(password)) criteria++;
    if (RegExp(r'[@$!%*?&]').hasMatch(password)) criteria++;
    
    setState(() {
      _passwordStrength = criteria / 5.0;
      
      switch (criteria) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential.user != null) {
        // Update user display name
        await credential.user!.updateDisplayName(_nameController.text.trim());
        
        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'role': 'user',
          'profileCompleted': true,
        });

        if (mounted) {
          // Navigate directly to main app since user is already authenticated
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainAppNavigator(),
            ),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome ${_nameController.text.trim()}! Account created successfully.'),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 3),
            ),
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
          message = 'An account already exists with this email.';
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
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  validator: _validateName,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
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
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  style: AppTheme.bodyLarge,
                  onChanged: (value) {
                    // Trigger real-time validation and password strength calculation
                    _calculatePasswordStrength(value);
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
