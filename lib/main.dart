import 'package:flutter/material.dart';

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
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Sync - Working'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Team Sync App Running!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Import welcome screen
import 'Screens/welcome-page1.dart';
import 'Screens/login-page.dart';
import 'Screens/create_account.dart';
import 'Screens/Dashboard.dart';
import 'Screens/ForgetPassword.dart';
import 'Screens/TaskManagerNew.dart' as TaskManagerLib;
// import 'Screens/TaskManager.dart';
import 'Screens/Profile.dart';
import 'Screens/Calendar.dart';
import 'Screens/Chat.dart';
import 'Screens/CreateaNewProject.dart';
import 'Screens/AddTeamMembers.dart';
import 'Screens/Notifications.dart';
import 'Screens/AboutTaskSync.dart';
import 'Screens/ContactSupport.dart';
import 'Screens/EditProfile.dart';
import 'Screens/ChangePassword.dart';

// UI Components
// Add this import

// Form Components

// Button Components

// Profile Components

// Add error handler import

void main() async {
  // Ensure Flutter is initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling - don't let it block the app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("⚠️ Firebase initialization failed: $e");
    print("🔄 App will continue without Firebase features");
  }
  
  // Set up basic error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorMessage = details.exception.toString();
    
    // Handle common errors gracefully
    if (errorMessage.contains('registerExtension') || 
        errorMessage.contains('developer event method hooks') ||
        errorMessage.contains('PigeonUserDetails') || 
        errorMessage.contains('List<Object?>') ||
        errorMessage.contains('PigeonUserInfo')) {
      if (kDebugMode) {
        print('🛠️ Non-critical error (handled): ${details.exception}');
      }
      return;
    }
    
    // Handle other errors normally
    if (kDebugMode) {
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
      title: 'TaskSync',
      theme: ThemeData(
        primarySwatch: Colors.blue,        colorScheme: ColorScheme.fromSeed(
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
      ),      debugShowCheckedModeBanner: false,
      home: const WelcomePage1(), // Back to WelcomePage1
      routes: {
        '/welcome1': (context) => const WelcomePage1(),
        '/welcome2': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const CreateAccount(),
        '/dashboard': (context) => const Dashboard(),
        '/forgot-password': (context) => const ForgetPasswordScreen(),
        '/taskmanager': (context) => const TaskManagerLib.TaskManager(),
        '/profile': (context) => const ProfileScreen(),
        '/calendar': (context) => const Calendar(),
        '/chat': (context) => const ChatScreen(),
        '/create-project': (context) => const CreateANewProject(),
        '/add-members': (context) => const AddTeamMembers(),
        '/notifications': (context) => const NotificationsScreen(),
        '/about': (context) => const AboutTaskSync(),
        '/contact': (context) => const ContactSupport(),
        '/edit-profile': (context) => const EditProfile(),
        '/change-password': (context) => const ChangePassword(),
      },
    );
  }
}

// TaskManager Wrapper to fix constructor issue
class TaskManagerWrapper extends StatelessWidget {
  const TaskManagerWrapper({super.key});
    @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text('Task Manager Wrapper', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Direct access to Task Manager', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkBypassMode(),
      builder: (context, bypassSnapshot) {
        // If checking bypass mode, show loading
        if (bypassSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If bypass mode is enabled, go directly to dashboard
        if (bypassSnapshot.hasData && bypassSnapshot.data == true) {
          return const Dashboard();
        }
        
        // Otherwise, check Firebase auth state
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show loading while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // If user is logged in, go to dashboard
            if (snapshot.hasData && snapshot.data != null) {
              return const Dashboard();
            }
            
            // If no user, show welcome page
            return const WelcomePage1();
          },
        );
      },
    );
  }
  
  Future<bool> _checkBypassMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('bypass_mode') ?? false;
    } catch (e) {
      return false;
    }
  }
}
