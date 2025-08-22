import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';

class PasswordResetHandler extends StatefulWidget {
  final String? actionCode;
  final String? continueUrl;

  const PasswordResetHandler({
    super.key,
    this.actionCode,
    this.continueUrl,
  });

  @override
  State<PasswordResetHandler> createState() => _PasswordResetHandlerState();
}

class _PasswordResetHandlerState extends State<PasswordResetHandler> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isValidCode = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordResetSuccess = false;
  String? _userEmail;
  
  // Password validation
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;
  List<String> _passwordCriteria = [];

  @override
  void initState() {
    super.initState();
    _verifyActionCode();
    _newPasswordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Verify the Firebase action code
  Future<void> _verifyActionCode() async {
    if (widget.actionCode == null || widget.actionCode!.isEmpty) {
      _showError('Invalid or missing reset code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify the password reset code
      final email = await FirebaseAuth.instance.verifyPasswordResetCode(widget.actionCode!);
      
      setState(() {
        _isValidCode = true;
        _userEmail = email;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Invalid or expired reset link.';
      
      switch (e.code) {
        case 'expired-action-code':
          errorMessage = 'This reset link has expired. Please request a new one.';
          break;
        case 'invalid-action-code':
          errorMessage = 'Invalid reset link. Please request a new password reset.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found. The user may have been deleted.';
          break;
      }
      
      _showError(errorMessage);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showError('An unexpected error occurred: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Update password strength meter
  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
    int score = 0;
    List<String> criteria = [];

    // Check password criteria
    if (password.length >= 8) {
      score += 20;
      criteria.add('✅ At least 8 characters');
    } else {
      criteria.add('❌ At least 8 characters');
    }

    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 20;
      criteria.add('✅ Uppercase letter');
    } else {
      criteria.add('❌ Uppercase letter');
    }

    if (password.contains(RegExp(r'[a-z]'))) {
      score += 20;
      criteria.add('✅ Lowercase letter');
    } else {
      criteria.add('❌ Lowercase letter');
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      score += 20;
      criteria.add('✅ Number');
    } else {
      criteria.add('❌ Number');
    }

    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 20;
      criteria.add('✅ Special character');
    } else {
      criteria.add('❌ Special character (!@#\$%^&*)');
    }

    setState(() {
      _passwordStrength = score / 100.0;
      _passwordCriteria = criteria;
      
      if (score >= 80) {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.green;
      } else if (score >= 60) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = Colors.orange;
      } else if (score >= 40) {
        _passwordStrengthText = 'Fair';
        _passwordStrengthColor = Colors.amber;
      } else {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.red;
      }
    });
  }

  /// Validate new password
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Reset password with new password
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordStrength < 0.6) {
      _showError('Please choose a stronger password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Confirm password reset with the new password
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.actionCode!,
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _passwordResetSuccess = true;
        _isLoading = false;
      });

      _showSuccess('Password reset successfully! You can now login with your new password.');
      
      // Navigate to login after a short delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to reset password.';
      
      switch (e.code) {
        case 'expired-action-code':
          errorMessage = 'Reset link has expired. Please request a new one.';
          break;
        case 'invalid-action-code':
          errorMessage = 'Invalid reset link. Please request a new password reset.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please choose a stronger password.';
          break;
      }
      
      _showError(errorMessage);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showError('An unexpected error occurred: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reset Password',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading && !_isValidCode
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verifying reset link...'),
                  ],
                ),
              )
            : _isValidCode
              ? _buildPasswordResetForm()
              : _buildErrorView(),
        ),
      ),
    );
  }

  Widget _buildPasswordResetForm() {
    if (_passwordResetSuccess) {
      return _buildSuccessView();
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          const Center(
            child: TickLogo(
              size: 80,
              color: AppTheme.primaryBlue,
              backgroundColor: AppTheme.backgroundLight,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Create New Password',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // User email
          if (_userEmail != null)
            Text(
              'for $_userEmail',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 32),
          
          // New Password Field
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            validator: _validateNewPassword,
            style: AppTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Password Strength Indicator
          if (_newPasswordController.text.isNotEmpty) ...[
            LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Password Strength:',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                ),
                Text(
                  _passwordStrengthText,
                  style: AppTheme.bodySmall.copyWith(
                    color: _passwordStrengthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _passwordCriteria.map((criteria) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      criteria,
                      style: AppTheme.bodySmall.copyWith(
                        color: criteria.startsWith('✅') ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            style: AppTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
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
          
          const SizedBox(height: 32),
          
          // Reset Password Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
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
                      Text('Updating Password...', style: AppTheme.buttonText),
                    ],
                  )
                : const Text(
                    'Update Password',
                    style: AppTheme.buttonText,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Password Updated!',
          style: AppTheme.headingLarge.copyWith(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Your password has been successfully updated.\nYou can now login with your new password.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Redirecting to login...',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'Invalid Reset Link',
          style: AppTheme.headingLarge.copyWith(
            color: Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'This password reset link is invalid or has expired.\nPlease request a new password reset.',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: AppTheme.textWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Back to Login', style: AppTheme.buttonText),
        ),
      ],
    );
  }
}
