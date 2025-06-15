// DIRECT LAUNCHER FOR TEAM SYNC APP
// This runs the TaskManager directly without using routes

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/Screens/TaskManager.dart';

void main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Launch the app
  runApp(const DirectLaunchApp());
}

class DirectLaunchApp extends StatelessWidget {
  const DirectLaunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Sync Direct',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1989BD),
          primary: const Color(0xFF1989BD),
          secondary: const Color(0xFF192F5D),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SafeArea(
        child: Scaffold(
          body: TaskManager(),
        ),
      ),
    );
  }
}
