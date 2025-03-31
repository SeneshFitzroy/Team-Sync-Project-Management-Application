import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Screens/Dashboard.dart';

class AuthHelper {
  /// Safe sign-in wrapper to handle the PigeonUserDetails cast error
  static Future<User?> safeSignInWithEmailAndPassword({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    try {
      // First attempt - direct sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // If successful, return the current user
      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>') ||
          e.toString().contains('PigeonUserInfo')) {
        
        print("Caught Firebase Pigeon error during sign-in: $e");
        
        // Try the fallback approach:
        // 1. Check if the email/password is valid by using fetchSignInMethods
        // 2. If valid, attempt signInWithEmailAndPassword again but ignore errors
        try {
          final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
          if (methods.contains('password')) {
            print("Valid email/password combination found, attempting alternative sign-in");
            
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
            } catch (signInError) {
              print("Expected error during alternative sign-in: $signInError");
            }
            
            // Check if user is actually signed in, despite the error
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              print("User is actually signed in (uid: ${user.uid}) despite the error");
              
              // If context is provided, navigate to Dashboard
              if (context != null && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              }
              
              return user;
            }
          } else {
            // No valid sign-in methods for this email
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user found for that email.',
            );
          }
        } catch (checkError) {
          if (checkError is! FirebaseAuthException) {
            print("Error during alternative sign-in check: $checkError");
          }
          rethrow;
        }
      }
      
      // Re-throw other errors
      rethrow;
    }
  }
  
  /// Safe method to get current user that won't throw the PigeonUserDetails error
  static User? getCurrentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }
}
