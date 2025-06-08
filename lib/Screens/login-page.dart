import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create account.dart';
import 'ForgetPassword2.dart';
import 'Dashboard.dart';

class LoginPage extends StatefulWidget {
  final String? initialEmail;
  final bool checkExistingLogin;
  
  const LoginPage({
    super.key,
    this.initialEmail,
    this.checkExistingLogin = true,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  @override
  void initState() {
    super.initState();
    
    // If an initial email is provided, use it
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
      _rememberMe = false; // Don't auto-remember when coming from account creation
    }
    
    // Only check for remembered user if we should and no initial email was provided
    if (widget.checkExistingLogin && (widget.initialEmail == null || widget.initialEmail!.isEmpty)) {
      _checkRememberedUser();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if user wants to be remembered
  Future<void> _checkRememberedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe && savedEmail != null) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Error checking remembered user: $e');
    }
  }

  // Save user preferences
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      print('Error saving user preferences: $e');
    }  }
  // Login function
  Future<void> _login() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Skip validation for testing - allow any input
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });
    
    try {
      // Get email (no validation needed for bypass)
      final email = _emailController.text.trim();
      
      // BYPASS AUTHENTICATION - Go directly to dashboard
      // Simulate a short loading time
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Save preferences (using mock data)
      await _saveUserPreferences();
      
      // Save mock login session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', 'mock_user_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_email', email.isNotEmpty ? email : 'test@example.com');
      await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
      await prefs.setBool('bypass_mode', true); // Add bypass mode flag

      if (mounted) {
        // Show success message briefly before navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! Redirecting to dashboard...'),
            backgroundColor: Color(0xFF667EEA),
            duration: Duration(seconds: 1),
          ),
        );
        
        // Small delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate directly to Dashboard instead of using named route
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      }
    } catch (e) {
      // In case of any unexpected error, still allow login for testing
      print('Login bypass - ignoring error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login bypassed! Redirecting to dashboard...'),
            backgroundColor: Color(0xFF667EEA),
            duration: Duration(seconds: 1),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
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

  // Check if form can be submitted - Allow any input for testing
  bool get _canSubmit {
    return !_isLoading; // Only check if not loading, allow any input
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Welcome back text
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                  Text(
                  'Sign in to continue with TaskSync',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Bypass mode indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Testing Mode: You can login with any credentials or leave fields empty',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),// Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  // validator: _validateEmail, // Removed for bypass
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA)),
                    ),
                    suffixIcon: _emailController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _emailController.clear()),
                          )
                        : null,
                  ),                  onChanged: (_) => setState(() {
                    _emailError = null;
                  }),
                  onTap: () => setState(() {
                    _emailError = null;
                  }),
                ),
                const SizedBox(height: 16),                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  // validator: _validatePassword, // Removed for bypass
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    errorText: _passwordError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  onFieldSubmitted: (_) => _login(),                  onChanged: (_) => setState(() {
                    _passwordError = null;
                  }),
                  onTap: () => setState(() {
                    _passwordError = null;
                  }),
                ),
                const SizedBox(height: 16),

                // Remember me and forgot password row
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF667EEA),
                    ),
                    const Text('Remember me'),
                    const Spacer(),                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPassword2(email: _emailController.text),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF667EEA),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _login : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )                        : const Text(
                            'Sign In (Bypass Mode)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateAccount(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF667EEA),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
