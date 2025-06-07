import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Auth import
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
// Import Firestore
// Import the helper
import '../utils/auth_helper.dart'; // Import AuthHelper
import 'create account.dart';
import 'ForgetPassword.dart';
import 'Dashboard.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this import

// Helper class to safely handle user data without casting issues
class SafeUserData {
  final String uid;
  final String? email;
  final String? displayName;

  SafeUserData({required this.uid, this.email, this.displayName});

  // Create from Firebase User safely without casting
  static SafeUserData fromFirebaseUser(User user) {
    return SafeUserData(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}

class LoginPage extends StatefulWidget {
  final bool checkExistingLogin;
  final String? initialEmail;

  const LoginPage({
    super.key, 
    this.checkExistingLogin = true,
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
  String? _emailError;
  String? _passwordError;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize Firebase Auth
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Add secure storage

  @override
  void initState() {
    super.initState();
    
    // Set initial email if provided
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
    
    // Load the remember me preference and saved credentials
    _loadRememberMePreference();

    // Only check for existing login if specified
    if (widget.checkExistingLogin) {
      _checkExistingLogin();
    }
  }

  // Load saved remember me preference and credentials
  Future<void> _loadRememberMePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rememberMe = prefs.getBool('rememberMe') ?? false;
      });

      // If remember me is enabled, load the saved credentials
      if (_rememberMe) {
        final savedEmail = await _secureStorage.read(key: 'saved_email');
        final savedPassword = await _secureStorage.read(key: 'saved_password');
        
        if (savedEmail != null && savedEmail.isNotEmpty) {
          setState(() {
            _emailController.text = savedEmail;
          });
        }
        
        if (savedPassword != null && savedPassword.isNotEmpty) {
          setState(() {
            _passwordController.text = savedPassword;
          });
        }
        
        print("Loaded saved credentials for email: $savedEmail");
      }

      // If remember me was previously set to false but user is logged in,
      // we should sign them out if we're not explicitly checking for login
      if (!_rememberMe && !widget.checkExistingLogin) {
        // Sign out only if we're not supposed to remember login
        await FirebaseAuth.instance.signOut();
        print("Signed out because 'Remember Me' was disabled");
      }
    } catch (e) {
      print("Error loading preferences: $e");
    }
  }

  // Save remember me preference and credentials
  Future<void> _saveRememberMePreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', value);
      
      if (value) {
        // Save credentials securely if remember me is enabled
        await _secureStorage.write(
          key: 'saved_email', 
          value: _emailController.text.trim()
        );
        await _secureStorage.write(
          key: 'saved_password', 
          value: _passwordController.text
        );
        print("Saved credentials for email: ${_emailController.text.trim()}");
      } else {
        // Clear saved credentials if remember me is disabled
        await _secureStorage.delete(key: 'saved_email');
        await _secureStorage.delete(key: 'saved_password');
        print("Cleared saved credentials");
      }
      
      print("Saved 'Remember Me' preference: $value");
    } catch (e) {
      print("Error saving preferences: $e");
    }
  }

  // Safer method to check existing login
  void _checkExistingLogin() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print("Auto-login: User already logged in with ID: ${currentUser.uid}");
        // Auto navigate to dashboard if user is already logged in
        Future.delayed(Duration.zero, () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          }
        });
      } else {
        print("No existing user found, showing login screen");
      }
    } catch (e) {
      print("Firebase Auth error in initState: $e");
      // Continue without checking logged-in state if Firebase is unavailable
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Replace _directLoginWithoutCustomObjects method with this updated version
  Future<void> _directLoginWithoutCustomObjects() async {
    try {
      // Check if the email exists in Firebase before attempting login
      // This can help identify if the email exists before trying password validation
      bool emailExists = await _checkIfEmailExists(_emailController.text.trim());
      
      if (!emailExists) {
        setState(() {
          _emailError = 'No user found with this email';
        });
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this email',
        );
      }
      
      // Proceed with login attempt since email exists
      final user = await AuthHelper.safeSignInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        context: context,
      );
      
      if (user != null) {
        print("Login successful with basic approach. User ID: ${user.uid}");
        
        // Store minimal user info in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.uid);
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
        
        if (mounted) {
          // Navigate to Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        }
      } else {
        throw Exception("Login appeared successful but no current user found");
      }
    } catch (e) {
      print("Error in direct login approach: $e");
      rethrow; // Re-throw for proper handling
    }
  }

  // Add this method to check if an email exists in Firebase Auth
  Future<bool> _checkIfEmailExists(String email) async {
    try {
      // This is a workaround to check if an email exists
      // We'll use the password reset functionality to check
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      // If the above line didn't throw, the email exists
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("Email check: User not found");
        return false;
      }
      // For any other exception, we'll assume the email might exist
      // This prevents giving away too much information on errors
      print("Email check exception: ${e.code}");
      return true;
    } catch (e) {
      print("General email check error: $e");
      // Again, for general errors, assume the email might exist
      return true;
    }
  }

  // Modify the error handler to be more user-friendly
  void _handleLoginError(dynamic error) {
    if (!mounted) return;
    
    String errorMessage = 'Login failed';
    
    // Special handling for the PigeonUserDetails error
    if (error.toString().contains('PigeonUserDetails')) {
      print("Detected PigeonUserDetails error: ${error.toString()}");
      
      // Try emergency navigation - the user might actually be logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print("User appears to be logged in despite PigeonUserDetails error");
        
        // Navigate to Dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        });
        return;
      }
      
      errorMessage = 'Login error: Authentication data format issue';
    } 
    // Handle Firebase Auth specific errors
    else if (error is FirebaseAuthException) {
      print("FirebaseAuthException: ${error.code} - ${error.message}");
      
      switch (error.code) {
        case 'user-not-found':
          setState(() { _emailError = 'No user found with this email'; });
          return;
        case 'wrong-password':
          setState(() { _passwordError = 'Incorrect password'; });
          return;
        case 'invalid-email':
          setState(() { _emailError = 'Invalid email format'; });
          return;
        case 'user-disabled':
          setState(() { _emailError = 'This account has been disabled'; });
          return;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Login error: ${error.message}';
      }
    } else {
      errorMessage = 'Login error: ${error.toString()}';
    }
    
    // Show error message to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Alternative login implementation without email existence check
  Future<void> _loginWithoutEmailCheck() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Try direct Firebase signIn instead of using AuthHelper
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Save remember me preference only on successful login
        await _saveRememberMePreference(_rememberMe);
        
        // Get the user from credential
        final user = credential.user;
        
        if (user != null) {
          print("Login successful with direct Firebase approach. User ID: ${user.uid}");
          
          // Store minimal user info in shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', user.uid);
          await prefs.setString('user_email', user.email ?? '');
          await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
          
          if (mounted) {
            // Navigate to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_rememberMe
                    ? 'Login successful! You will stay logged in.'
                    : 'Login successful!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          throw Exception("Login appeared successful but no user returned");
        }
      } catch (e) {
        _handleLoginError(e);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Replace the existing _login method with this one that uses the alternative approach
  Future<void> _login() async {
    await _loginWithoutEmailCheck();
  }

  bool get _canSubmit {
    // Only enable the login button when both fields have content
    return _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F8FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: Container(
              width: 39,
              height: 39,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFD8DADC),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'loginLogo',
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Team Sync',
                        style: TextStyle(
                          color: Color(0xFF192F5D),
                          fontSize: 28,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Log in',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      height: 1.30,
                      letterSpacing: -0.30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome back! Enter your details to continue',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  _buildRememberForgotRow(),
                  const SizedBox(height: 30),
                  _buildLoginButton(),
                  const SizedBox(height: 40),
                  _buildSignUpPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF666666)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8DADC), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8DADC), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF192F5D), width: 1.5),
            ),
            errorText: _emailError,
            suffixIcon: _emailController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF666666)),
                    onPressed: () => setState(() => _emailController.clear()),
                  )
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          onChanged: (_) => setState(() {
            _emailError = null;
          }),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF666666)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8DADC), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8DADC), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF192F5D), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF666666),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onFieldSubmitted: (_) => _login(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          onChanged: (_) => setState(() {
            _passwordError = null;
          }),
        ),
      ],
    );
  }

  Widget _buildRememberForgotRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
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
                  // Don't save here; save on successful login
                },
                activeColor: const Color(0xFF192F5D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Remember me',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF192F5D),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canSubmit ? _login : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF192F5D),
          disabledBackgroundColor: const Color(0xFF192F5D).withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Log in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAccount()),
          );
        },
        child: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Dont have an account? ',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Sign up',
                style: TextStyle(
                  color: Color(0xFF192F5D),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Override the sign out method to also clear remember me when explicitly signing out
  static Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Also clear the remember me setting when explicitly signing out
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', false);
      
      // Clear saved credentials
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'saved_email');
      await secureStorage.delete(key: 'saved_password');

      print("User signed out successfully, remember me and saved credentials cleared");
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// This main function should be removed when integrating with your actual app
// It's just here for testing the login page independently
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: LoginPage(checkExistingLogin: false),
    ),
            ));
}
