import 'package:flutter/material.dart';
import 'Screens/welcome-page1.dart';
import 'Screens/welcome-page2.dart';
import 'Screens/login_working.dart';
import 'Screens/dashboard_complete.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Sync - Project Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1A365D),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A365D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A365D),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage1(),
        '/welcome2': (context) => const WelcomePage2(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const Dashboard(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
