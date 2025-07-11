import 'package:flutter/material.dart';
import 'Screens/welcome-page1.dart';
import 'Screens/welcome-page2.dart';
import 'Screens/login-page.dart';
import 'Screens/create_account.dart';
import 'Screens/Dashboard.dart';
import 'Screens/Profile.dart';
import 'Screens/TaskManager.dart';
import 'Screens/Calendar.dart';
import 'Screens/Chat.dart';
import 'Screens/Notifications.dart';
import 'Screens/EditProfile.dart';
import 'Screens/ChangePassword.dart';
import 'Screens/ContactSupport.dart';
import 'Screens/CreateaNewProject.dart';

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
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage1(),
        '/welcome2': (context) => const WelcomePage2(),
        '/login': (context) => const LoginPage(),
        '/create-account': (context) => const CreateAccount(),
        '/dashboard': (context) => const Dashboard(),
        '/profile': (context) => const ProfileScreen(),
        '/tasks': (context) => const TaskManager(),
        '/calendar': (context) => const Calendar(),
        '/chat': (context) => const Chat(),
        '/notifications': (context) => const NotificationsScreen(),
        '/edit-profile': (context) => const EditProfile(),
        '/change-password': (context) => const ChangePassword(),
        '/contact-support': (context) => const ContactSupport(),
        '/create-project': (context) => const CreateaNewProject(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
