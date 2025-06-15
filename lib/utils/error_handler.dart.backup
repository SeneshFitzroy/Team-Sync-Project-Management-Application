import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Screens/Dashboard.dart';
import '../Screens/login-page.dart';

class ErrorHandler {
  /// Handle Firebase errors safely, especially PigeonUserDetails casting errors
  static void handleFirebaseError(
    dynamic error, 
    BuildContext context, 
    {VoidCallback? onHandled}
  ) {
    // Check for the specific PigeonUserDetails error
    if (error.toString().contains('PigeonUserDetails')) {
      print("PigeonUserDetails error detected: ${error.toString()}");
      
      // If we have a current user, the auth is probably successful despite the error
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proceeding despite data format issue'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Navigate to Dashboard, which should handle this situation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        
        if (onHandled != null) onHandled();
        return;
      }
      
      // If we don't have a user, show a better error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data format issue. Please try again or contact support.'),
          backgroundColor: Colors.red,
        ),
      );
      
      if (onHandled != null) onHandled();
      return;
    }
    
    // Handle other Firebase errors
    if (error is FirebaseAuthException) {
      String message;
      switch (error.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = error.message ?? 'Authentication error';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Generic error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    if (onHandled != null) onHandled();
  }
  
  /// Emergency recovery - use when app is in a bad state
  static void emergencyRecovery(BuildContext context) {
    // Sign out and go to login
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage(checkExistingLogin: false)),
        (route) => false,
      );
    }).catchError((e) {
      print("Error during emergency recovery: $e");
      // Force navigation anyway
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage(checkExistingLogin: false)),
        (route) => false,
      );
    });
  }
}
