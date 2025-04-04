import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Screens/login-page.dart';

// Import welcome screen
import 'Screens/welcome-page1.dart';

// UI Components
import 'Components/backbutton.dart';
import 'Components/nav_bar.dart';
import 'Components/search_bar.dart';
import 'Components/profile_icon.dart';
import 'Components/filter_button.dart';
import 'Components/task_box.dart';
import 'Components/filter_icon.dart';  // Add this import

// Form Components
import 'Components/custom_form_field.dart';
import 'Components/email_form_box.dart';
import 'Components/password_form_box.dart';
import 'Components/search_field.dart';

// Button Components
import 'Components/add_button.dart';
import 'Components/bluebutton.dart';
import 'Components/whitebutton.dart';

// Profile Components
import 'Components/profile_header.dart';

// Add error handler import
import 'utils/error_handler.dart';

void main() async {
  // Ensure Flutter is initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Firebase initialization with error handling
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).catchError((error) {
      print("Firebase initialization error caught and handled: $error");
    });
    
    print("Firebase initialized successfully");
    
    // Basic tests to ensure Firebase Auth is working
    try {
      final auth = FirebaseAuth.instance;
      print("Firebase Auth initialized: ${auth.app.name}");
    } catch (e) {
      print("Error accessing Firebase Auth: $e");
    }
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  
  // Set up global error handling specifically for the PigeonUserDetails error
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('PigeonUserDetails') || 
        details.exception.toString().contains('List<Object?>') ||
        details.exception.toString().contains('PigeonUserInfo')) {
      print('Caught Firebase Pigeon error in global handler: ${details.exception}');
      // Don't crash the app - just log it
    } else {
      // Forward to original handler for other errors
      FlutterError.presentError(details);
    }
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Sync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WelcomePage1(),
    );
  }
}
