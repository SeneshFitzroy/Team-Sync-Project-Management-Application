import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'Screens/clean_splash_screen.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CleanTeamSyncApp());
}

class CleanTeamSyncApp extends StatelessWidget {
  const CleanTeamSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Sync - Clean Demo',
      theme: AppTheme.lightTheme,
      home: const CleanSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
