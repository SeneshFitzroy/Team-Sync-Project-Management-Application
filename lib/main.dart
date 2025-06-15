import 'package:flutter/material.dart';
import 'Screens/welcome-page1.dart';
import 'Screens/welcome-page2.dart';
import 'Screens/login_working.dart';
import 'Screens/create_account.dart';
import 'Screens/dashboard_complete.dart';
import 'Screens/TaskManagerNew.dart';
import 'Screens/Profile.dart';
import 'Screens/Calendar.dart';
import 'Screens/CreateaNewProject.dart';
import 'Screens/AddTeamMembers.dart';
import 'Screens/Notifications.dart';
import 'Screens/ContactSupport.dart';
import 'Screens/EditProfile.dart';
import 'Screens/ChangePassword.dart';
import 'Screens/ForgetPassword.dart';
import 'Screens/ForgetPassword2.dart';
import 'Screens/ResetPassword.dart';
import 'Screens/AboutTaskSync.dart';
import 'Screens/Chat.dart';

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
        '/create-account': (context) => const CreateAccount(),
        '/dashboard': (context) => const Dashboard(),
        '/task-manager': (context) => const TaskManagerNew(),
        '/profile': (context) => const Profile(),
        '/calendar': (context) => const Calendar(),
        '/create-project': (context) => const CreateaNewProject(),
        '/add-team-members': (context) => const AddTeamMembers(),
        '/notifications': (context) => const Notifications(),
        '/contact-support': (context) => const ContactSupport(),
        '/edit-profile': (context) => const EditProfile(),
        '/change-password': (context) => const ChangePassword(),
        '/forget-password': (context) => const ForgetPassword(),
        '/forget-password2': (context) => const ForgetPassword2(),
        '/reset-password': (context) => const ResetPassword(),
        '/about': (context) => const AboutTaskSync(),
        '/chat': (context) => const Chat(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
