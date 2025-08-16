import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import welcome screen
import 'Screens/welcome-page1.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '✓ TaskSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D62ED),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF555555),
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF555555),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D62ED),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D62ED),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: const WelcomePage1(),
    );
  }
}
