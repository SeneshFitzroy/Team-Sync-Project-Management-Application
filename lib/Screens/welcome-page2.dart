import 'package:flutter/material.dart';
import 'package:fluttercomponenets/main.dart';
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
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // TaskSync Logo
              Image.asset(
                'assets/images/Logo.png',
                height: 300,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 16),

              // TaskSync Text Logo
              const Text(
                'TaskSync',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1989BD),
                ),
              ),

              const SizedBox(height: 8),

              // Project Management Text with line separators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 1,
                    color: const Color(0xFF1989BD),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'PROJECT MANAGEMENT',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Color(0xFF1989BD),
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 1,
                    color: const Color(0xFF1989BD),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Log in button (using BlueButton component with custom text)
              SizedBox(
                width: double.infinity,
                child: BlueButton(
                  text: 'Log in',
                  onPressed: () {
                    // Handle login action
                    print('Log in pressed');
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Create account button (using WhiteButton component with custom text)
              SizedBox(
                width: double.infinity,
                child: WhiteButton(
                  text: 'Create account',
                  onPressed: () {
                    // Navigate to the CreateAccount screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAccount()),
                    );
                  },
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// If the BlueButton or WhiteButton components don't accept custom text, here are modified versions
// that can be used instead of the imports (you can replace the imports with these if needed)

class BlueButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BlueButton({
    super.key,
    this.text = 'Continue',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF192F5D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class WhiteButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const WhiteButton({
    super.key,
    this.text = 'Skip',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF192F5D),
        side: const BorderSide(color: Color(0xFF192F5D)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
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
      backgroundColor: const Color(0xFFF0F8FF),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Logo Image
              Positioned(
                left: -65,
                top: 97,
                child: Container(
                  width: 523,
                  height: 523,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // Login Button
              Positioned(
                left: 20,
                top: 620,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the LoginPage screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: Container(
                    width: 353,
                    height: 54,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF192F5D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Log in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Create Account Button
              Positioned(
                left: 20,
                top: 690,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the CreateAccount screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateAccount()),
                    );
                  },
                  child: Container(
                    width: 353,
                    height: 56,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF737373),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Create account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}