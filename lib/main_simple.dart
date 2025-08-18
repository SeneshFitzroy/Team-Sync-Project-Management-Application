import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'Screens/simple_splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Sync',
      theme: AppTheme.lightTheme,
      home: const SimpleSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
