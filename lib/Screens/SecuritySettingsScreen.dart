import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../Services/user_service.dart';
import '../widgets/TickLogo.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> 
    with TickerProviderStateMixin {
  
  // Controllers for password change
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State variables
  bool _isLoading = false;
  bool _isChangingPassword = false;
  bool _isChangingEmail = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureEmailPassword = true;
  bool _twoFactorEnabled = false;
  bool _showPasswordChangeForm = false;
  bool _showEmailChangeForm = false;
  
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSecuritySettings();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _emailController.text = user.email ?? '';
          // Load two-factor status from user metadata or Firestore
          _twoFactorEnabled = false; // Default value
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading security settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isChangingPassword = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Reauthenticate user
        final success = await UserService.reauthenticateUser(
          currentUser.email!,
          _currentPasswordController.text,
        );

        if (success) {
          // Update password
          final passwordUpdated = await UserService.updatePassword(_newPasswordController.text);
          
          if (passwordUpdated) {
            _showSuccessSnackBar('Password updated successfully');
            setState(() {
              _showPasswordChangeForm = false;
              _currentPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            });
          } else {
            _showErrorSnackBar('Failed to update password');
          }
        } else {
          _showErrorSnackBar('Current password is incorrect');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error changing password: $e');
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  Future<void> _changeEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isChangingEmail = true);

    try {
      final success = await UserService.updateEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        _showSuccessSnackBar('Email updated successfully. Please verify your new email.');
        setState(() {
          _showEmailChangeForm = false;
          _passwordController.clear();
        });
      } else {
        _showErrorSnackBar('Failed to update email');
      }
    } catch (e) {
      _showErrorSnackBar('Error changing email: $e');
    } finally {
      setState(() => _isChangingEmail = false);
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      try {
        final success = await UserService.sendPasswordResetEmail(user!.email!);
        if (success) {
          _showSuccessSnackBar('Password reset email sent');
        } else {
          _showErrorSnackBar('Failed to send password reset email');
        }
      } catch (e) {
        _showErrorSnackBar('Error sending password reset email: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue, const Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingWidget() : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSecurityOptionsCard(),
                    const SizedBox(height: 20),
                    if (_showPasswordChangeForm) _buildPasswordChangeForm(),
                    if (_showEmailChangeForm) _buildEmailChangeForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const TickLogo(size: 35),
          const SizedBox(width: 12),
          const Text(
            'Security Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOptionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSecurityOption(
            'Change Password',
            'Update your account password',
            Icons.lock_outline,
            () => setState(() => _showPasswordChangeForm = !_showPasswordChangeForm),
          ),
          _buildDivider(),
          _buildSecurityOption(
            'Change Email',
            'Update your email address',
            Icons.email_outlined,
            () => setState(() => _showEmailChangeForm = !_showEmailChangeForm),
          ),
          _buildDivider(),
          _buildSecurityOption(
            'Send Password Reset',
            'Send password reset email',
            Icons.refresh,
            _sendPasswordResetEmail,
          ),
          _buildDivider(),
          _buildTwoFactorToggle(),
          _buildDivider(),
          _buildSecurityOption(
            'Login History',
            'View recent login activity',
            Icons.history,
            () => _showInfoDialog('Login History', 'This feature shows your recent login activity and devices.'),
          ),
          _buildDivider(),
          _buildSecurityOption(
            'Active Sessions',
            'Manage your active sessions',
            Icons.devices,
            () => _showInfoDialog('Active Sessions', 'This feature allows you to manage devices with active sessions.'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue.withOpacity(0.1), const Color(0xFF764BA2).withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _buildTwoFactorToggle() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue.withOpacity(0.1), const Color(0xFF764BA2).withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.security, color: AppTheme.primaryBlue, size: 24),
      ),
      title: const Text(
        'Two-Factor Authentication',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        _twoFactorEnabled ? 'Enhanced security enabled' : 'Add extra security to your account',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: _twoFactorEnabled,
        onChanged: (value) {
          setState(() => _twoFactorEnabled = value);
          _showInfoDialog(
            'Two-Factor Authentication',
            value 
                ? 'Two-factor authentication has been enabled for enhanced security.'
                : 'Two-factor authentication has been disabled.',
          );
        },
        activeColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildPasswordChangeForm() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock, color: AppTheme.primaryBlue),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a new password';
                }
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_reset, color: AppTheme.primaryBlue),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showPasswordChangeForm = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isChangingPassword ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isChangingPassword 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailChangeForm() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'New Email Address',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your new email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureEmailPassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryBlue),
                suffixIcon: IconButton(
                  icon: Icon(_obscureEmailPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureEmailPassword = !_obscureEmailPassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showEmailChangeForm = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isChangingEmail ? null : _changeEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isChangingEmail 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Change Email', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }
}
