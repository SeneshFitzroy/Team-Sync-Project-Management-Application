import 'package:flutter/material.dart';
import 'create account.dart'; // Import the CreateAccount screen
import 'login-page.dart'; // Import the LoginPage screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1989BD)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1989BD), Color(0xFF192F5D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // TaskSync Logo
                Image.asset(
                  'assets/images/Logo.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 16),

                // TaskSync Text Logo
                const Text(
                  'TaskSync',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Project Management Text with line separators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSeparator(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'PROJECT MANAGEMENT',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildSeparator(),
                  ],
                ),

                const Spacer(flex: 3),

                // Log in button
                _buildButton(
                  context,
                  text: 'Log in',
                  color: Colors.white,
                  textColor: const Color(0xFF192F5D),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Create account button
                _buildButton(
                  context,
                  text: 'Create account',
                  color: Colors.transparent,
                  textColor: Colors.white,
                  borderColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAccount()),
                    );
                  },
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.white,
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          side: borderColor != null ? BorderSide(color: borderColor) : null,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class WelcomePage2 extends StatelessWidget {
  const WelcomePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF192F5D), Color(0xFF1989BD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // Logo Image
                Positioned(
                  left: -65,
                  top: 97,
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: 523,
                    height: 523,
                    fit: BoxFit.contain,
                  ),
                ),

                // Login Button
                _buildPositionedButton(
                  context,
                  top: 620,
                  text: 'Log in',
                  color: Colors.white,
                  textColor: const Color(0xFF192F5D),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),

                // Create Account Button
                _buildPositionedButton(
                  context,
                  top: 690,
                  text: 'Create account',
                  color: Colors.transparent,
                  textColor: Colors.white,
                  borderColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAccount()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedButton(
    BuildContext context, {
    required double top,
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return Positioned(
      left: 20,
      top: top,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 353,
          height: 54,
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedRectangleBorder(
              side: borderColor != null
                  ? BorderSide(color: borderColor, width: 1)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}