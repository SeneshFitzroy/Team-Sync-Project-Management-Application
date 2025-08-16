import 'package:flutter/material.dart';
import 'create account.dart';
import 'login-page.dart';
import '../widgets/TickLogo.dart';
import '../theme/app_theme.dart';

class WelcomePage2 extends StatelessWidget {
  const WelcomePage2({super.key});

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
                const TickLogoLarge(
                  size: 250,
                  tickColor: Colors.white,
                  backgroundColor: Color(0xFF2D62ED),
                ),

                const SizedBox(height: 16),

                // TaskSync Text Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TaskSync',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
                    // Navigate directly to login page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
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