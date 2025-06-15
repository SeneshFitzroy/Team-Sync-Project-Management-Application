import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Import screens - using relative imports to avoid package issues
import 'Screens/welcome-page1.dart';
import 'Screens/login-page.dart';
import 'Screens/create_account.dart';
import 'Screens/Dashboard.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Simple error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
    }
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Sync - Project Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1989BD),
          primary: const Color(0xFF1989BD),
          secondary: const Color(0xFF192F5D),
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1989BD),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomePage1(),
      routes: {
        '/welcome': (context) => const WelcomePage1(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const CreateAccount(),
        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}
