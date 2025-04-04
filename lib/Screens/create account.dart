import 'package:flutter/material.dart';
import 'login-page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore for user data
import 'package:flutter/foundation.dart';
import '../firebase_options.dart'; // Import Firebase options

// Simple user model to replace PigeonUserDetails and avoid casting issues
class UserData {
  final String displayName;
  final String email;
  final String userId;
  final DateTime createdAt;

  UserData({
    required this.displayName,
    required this.email,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(), // Store as string to avoid timestamp issues
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}

// Ensure Firebase is initialized before using it
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FigmaToCodeApp());
}

// Generated by: https://www.figma.com/community/plugin/842128343887142055/
class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          CreateAccount(),
        ]),
      ),
    );
  }
}

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  String _passwordStrength = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Simplified navigation method with forceful approach
  void _navigateToLoginPage() {
    final email = _emailController.text.trim();
    
    print("Navigating to login page with email: $email");
    
    // Use a more direct approach to navigation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(
          initialEmail: email,
          checkExistingLogin: false,
        ),
      ),
    );
  }

  // Keep the emergency method as a fallback
  void _emergencyNavigateToLogin() {
    try {
      print("Using emergency navigation method");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print("Emergency navigation failed: $e");
      // Try one more time with a delayed approach
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    }
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final displayName = _nameController.text;
        
        print("Creating account with email: $email");
        
        // Create Firebase Auth user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // IMPORTANT: Instead of using the credential result, use currentUser directly
        final user = FirebaseAuth.instance.currentUser;
        
        if (user != null) {
          print("Account created with UID: ${user.uid}");
           
          try {
            // Create a simple map of user data - avoid complex objects
            final Map<String, dynamic> userMap = {
              'displayName': displayName,
              'email': email,
              'userId': user.uid,
              'createdAt': DateTime.now().toIso8601String(),
              'isActive': true,
              'lastLogin': null,
            };
            
            // Store as a document, ensure it's a Map not a List
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set(userMap);
                
            print("User data saved to Firestore: $userMap");
            
            // Sign out to clear any state
            await FirebaseAuth.instance.signOut();
            print("User signed out after account creation");
            
            // Don't setState loading here
            
            // Show success message first
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
            
            // IMPORTANT: Use a much more direct approach with pushReplacement
            print("Navigating directly to login page...");
            
            // Remove WidgetsBinding and any delay - go immediately to login
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(
                  initialEmail: email,
                  checkExistingLogin: false,
                ),
              ),
              (route) => false, // Remove all previous routes
            );
            
            // Don't return early - let the code continue to handle errors properly
          } catch (firestoreError) {
            print("Error saving data to Firestore: $firestoreError");
            
            // Check if error contains PigeonUserDetails - this is our specific issue
            if (firestoreError.toString().contains("PigeonUserDetails")) {
              print("DETECTED CRITICAL ERROR: PigeonUserDetails casting issue");
              
              // Try to recover - sign out if possible
              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                print("Could not sign out: $e");
              }
              
              // Show success anyway - the account was created in Firebase Auth
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account created but profile setup failed. You can update it later.'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
                
                // Use emergency navigation
                _emergencyNavigateToLogin();
              }
            } else {
              _handleSuccessWithoutFirestore();
            }
          }
        } else {
          throw Exception("Failed to create user account");
        }
      } catch (e) {
        if (e is FirebaseAuthException) {
          _handleFirebaseAuthError(e);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error: $e';
          });
        }
        
        print("Error creating account: $e");
      }
      
      // Only set loading to false if still mounted and we haven't navigated
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle successful auth but failed Firestore
  void _handleSuccessWithoutFirestore() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created but profile data not saved. You can update it later.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      
      _navigateToLoginPage();
    }
  }

  // Helper method to handle FirebaseAuthException
  void _handleFirebaseAuthError(FirebaseAuthException e) {
    setState(() {
      _isLoading = false;
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          _errorMessage = 'Please provide a valid email address.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          _errorMessage = 'Error: ${e.message}';
      }
    });
  }
  
  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
      } else if (password.length < 6) {
        _passwordStrength = 'Weak';
      } else if (password.length < 10) {
        _passwordStrength = 'Moderate';
      } else {
        _passwordStrength = 'Strong';
      }
    });
  }

  // Add this method to debug any issues with Firestore
  void _debugFirestoreData(String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await docRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.data();
        print("USER DATA IN FIRESTORE: $data");
        print("DATA TYPE: ${data.runtimeType}");
      } else {
        print("NO USER DATA FOUND IN FIRESTORE FOR ID: $userId");
      }
    } catch (e) {
      print("ERROR DEBUGGING FIRESTORE: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 800,
              ),
              Positioned(
                left: 20,
                top: 50,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 39,
                    height: 39,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          width: 1,
                          color: const Color(0xFFD8DADC),
                        ),
                      ),
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 137,
                child: SizedBox(
                  width: 339,
                  child: Text(
                    'Create account',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      height: 1.30,
                      letterSpacing: -0.30,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 200,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your full name',
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: const Color(0xFFD8DADC)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: const Color(0xFFD8DADC)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Create a password',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: _checkPasswordStrength,
                          decoration: InputDecoration(
                            hintText: 'must be 8 characters',
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD8DADC)),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Password Strength: $_passwordStrength',
                          style: TextStyle(
                            color: _passwordStrength == 'Strong'
                                ? Colors.green
                                : _passwordStrength == 'Moderate'
                                    ? Colors.orange
                                    : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Confirm password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'repeat password',
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: const Color(0xFFD8DADC)),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
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
                        SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                ),
                              GestureDetector(
                                onTap: _isLoading ? null : _createAccount,
                                child: Container(
                                  width: 353,
                                  height: 56,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF192F5D),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            'Create Account',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.7),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Log in',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}