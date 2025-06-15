import 'package:flutter/material.dart';
import 'Screens/welcome-page1.dart';
import 'Screens/welcome-page2.dart';
import 'Screens/login_simple.dart';
import 'Screens/Dashboard.dart';

void main() {
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
