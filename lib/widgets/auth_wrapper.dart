import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/auth_service.dart';
import '../Screens/welcome-page1.dart';
import '../Screens/Dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is authenticated, show Dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return const Dashboard();
        }
        
        // If user is not authenticated, show Welcome page
        return const WelcomePage1();
      },
    );
  }
}
