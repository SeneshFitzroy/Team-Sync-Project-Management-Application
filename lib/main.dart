import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

// Screens
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/password_changed_screen.dart';
import 'screens/main_app_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/create_project_screen.dart';
import 'screens/add_team_members_screen.dart';
import 'screens/task_management_screen.dart';
import 'screens/kanban_board_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/about_tasksync_screen.dart';
import 'screens/contact_support_screen.dart';

// BLoCs
import 'blocs/auth_bloc.dart';
import 'blocs/project_bloc.dart';
import 'blocs/task_bloc.dart';

// Services
import 'services/auth_service.dart';
import 'services/firebase_service.dart';

// Theme
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(TaskSyncApp());
}

class TaskSyncApp extends StatelessWidget {
  TaskSyncApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => OTPVerificationScreen(
          email: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/password-changed',
        builder: (context, state) => const PasswordChangedScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainAppScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/create-project',
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: '/add-team-members',
        builder: (context, state) => AddTeamMembersScreen(
          projectId: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/task-management',
        builder: (context, state) => TaskManagementScreen(
          projectId: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/kanban-board',
        builder: (context, state) => KanbanBoardScreen(
          projectId: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/add-task',
        builder: (context, state) => AddTaskScreen(
          projectId: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/chat-list',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => ChatScreen(
          recipientName: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/about-tasksync',
        builder: (context, state) => const AboutTaskSyncScreen(),
      ),
      GoRoute(
        path: '/contact-support',
        builder: (context, state) => const ContactSupportScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthService()),
        ),
        BlocProvider<ProjectBloc>(
          create: (context) => ProjectBloc(FirebaseService()),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(FirebaseService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'TaskSync',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
