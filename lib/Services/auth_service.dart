import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Check if user is already logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    
    // If remember me is false, we should sign out any existing user
    if (!rememberMe) {
      await _auth.signOut();
      return false;
    }
    
    // Otherwise check for current user
    return _auth.currentUser != null;
  }
  
  // Sign out and handle remember me
  static Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      
      // Clear the remember me preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', false);
      
      print("User signed out successfully and remember me cleared");
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
