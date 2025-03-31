import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttercomponenets/services/Notification_service.dart';

// Import welcome screen
import 'Screens/welcome-page1.dart';

// UI Components
import 'Components/backbutton.dart';
import 'Components/nav_bar.dart';
import 'Components/search_bar.dart';
import 'Components/profile_icon.dart';
import 'Components/filter_button.dart';
import 'Components/task_box.dart';
import 'Components/filter_icon.dart';  // Add this import

// Form Components
import 'Components/custom_form_field.dart';
import 'Components/email_form_box.dart';
import 'Components/password_form_box.dart';
import 'Components/search_field.dart';

// Button Components
import 'Components/add_button.dart';
import 'Components/bluebutton.dart';
import 'Components/whitebutton.dart';

// Profile Components
import 'Components/profile_header.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyAAX-5-79LUpH764TW3cVm_ra7a_muB2qc",
      authDomain: "team-sync-70fa7.firebaseapp.com",
      projectId: "team-sync-70fa7",
      storageBucket: "team-sync-70fa7.firebasestorage.app",
      messagingSenderId: "881519675369",
      appId: "1:881519675369:web:c6192f5fb599ca9b4b6d78",
      measurementId: "G-HBC1B46NKG"));
  }else{
    await Firebase.initializeApp();
    await NotificationService().init();
    await getFCMToken();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Components',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF192F5D)),
        useMaterial3: true, // Enabling Material 3 for a more modern design
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const OnboardingScreen(), // Set welcome screen as initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}

class FigmaToCodeApp extends StatefulWidget {
  const FigmaToCodeApp({super.key});

  @override
  State<FigmaToCodeApp> createState() => _FigmaToCodeAppState();
}

class _FigmaToCodeAppState extends State<FigmaToCodeApp> {
  int _taskProgress = 75;
  int _selectedNavIndex = 0;
  final TextEditingController _projectNameController = TextEditingController();

  void _updateTaskProgress(int progress) {
    setState(() {
      _taskProgress = progress;
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(),
        title: const Text('Tasks'),
        actions: [
          SearchIconButton(),
          const SizedBox(width: 8),
          FilterIcon(
            onPressed: () {
              print('Filter icon pressed');
            },
          ),
          const SizedBox(width: 8),
          ProfileIcon(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Logo at the top
            Center(
              child: Image.asset(
                'assets/images/Logo.png',
                height: 273, // Same height as ProfileHeader
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),

            // Filter Button
            FilterButton(
              onPressed: () {
                print('Filter button pressed');
              },
            ),
            const SizedBox(height: 24),

            // Profile Header
            ProfileHeader(
              name: 'Mandira De Silva',
              username: '@chukuru7',
              avatarUrl: 'https://example.com/avatar.jpg',
              onAvatarTap: () {
                print('Avatar tapped');
              },
            ),
            const SizedBox(height: 24),

            // Search bar
            SearchField(
              controller: TextEditingController(),
              onChanged: (value) {
                print('Searching for: $value');
              },
            ),
            const SizedBox(height: 24),
            
            // Form components section
            const Text(
              'Form Components',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192F5D),
              ),
            ),
            const SizedBox(height: 16),
            const EmailFormBox(
              label: 'Email',
              hint: 'Enter your email',
            ),
            const SizedBox(height: 16),
            const PasswordFormBox(
              label: 'Password',
              hint: 'Enter your password',
              initialObscureText: true,  // Changed from obscureText to initialObscureText to match the component parameter
            ),
            const SizedBox(height: 16),
            
            // Project Name Form Field
            CustomFormField(
              label: 'Project Name',
              hintText: 'Enter project name',
              controller: _projectNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
              onChanged: (value) {
                // Handle text changes
                print('Project name: $value');
              },
            ),
            const SizedBox(height: 24),
            
            // Button components section
            const Text(
              'Button Components',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192F5D),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: WhiteButton()),    // White button component
            const SizedBox(height: 16), // Space between buttons
            const Center(child: BlueButton()),     // Added the Blue button component here
            const SizedBox(height: 24),
            
            // Task components section
            const Text(
              'Task Components',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192F5D),
              ),
            ),
            const SizedBox(height: 16),
            
            // Interactive TaskBox
            TaskBox(
              title: 'Marketing Campaign',
              memberCount: 8,
              status: TaskStatus.active,
              progressPercentage: _taskProgress,
              accentColor: const Color(0xFF187E0F),
              onProgressChanged: _updateTaskProgress,
              memberAvatars: [
                'https://randomuser.me/api/portraits/men/32.jpg',
                'https://randomuser.me/api/portraits/women/44.jpg',
                'https://randomuser.me/api/portraits/men/46.jpg',
              ],
            ),
            
            const SizedBox(height: 24),
            Center(
              child: BlueButton(
                text: 'Create New Project',
                onPressed: () {
                  // Show project name from form field
                  if (_projectNameController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Project Name: ${_projectNameController.text}')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a project name')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            AddButton(
              onPressed: () {
                print('Add button pressed');
                // Add your action here
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
