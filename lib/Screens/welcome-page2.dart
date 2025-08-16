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
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // TaskSync Logo
              TickLogoLarge(
                size: 200,
                tickColor: AppTheme.primaryBlue,
                backgroundColor: AppTheme.backgroundLight,
              ),

              const SizedBox(height: 24),

              // TaskSync Text Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TaskSync',
                    style: AppTheme.headingLarge.copyWith(
                      fontSize: 32,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Project Management Text with line separators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSeparator(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'PROJECT MANAGEMENT',
                      style: AppTheme.bodySmall.copyWith(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
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
                color: AppTheme.primaryBlue,
                textColor: AppTheme.textWhite,
                onPressed: () {
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
                color: AppTheme.backgroundWhite,
                textColor: AppTheme.primaryBlue,
                borderColor: AppTheme.primaryBlue,
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