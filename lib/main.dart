import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'Screens/splash_screen.dart';
import 'Screens/login-page.dart';
import 'Screens/ResetPasswordPage.dart';
import 'blocs/dashboard_bloc.dart';
import 'blocs/project_bloc.dart';
import 'blocs/task_bloc.dart';
import 'blocs/member_request_bloc.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(),
        ),
        BlocProvider<ProjectBloc>(
          create: (context) => ProjectBloc(),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(),
        ),
        BlocProvider<MemberRequestBloc>(
          create: (context) => MemberRequestBloc(),
        ),
      ],
      child: MaterialApp(
        title: '✓ TaskSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/reset-password': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
            final actionCode = args?['actionCode'] ?? '';
            return ResetPasswordPage(actionCode: actionCode);
          },
        },
      ),
    );
  }
}
