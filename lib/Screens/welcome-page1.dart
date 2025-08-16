import 'package:flutter/material.dart';
import 'welcome-page2.dart';
import '../widgets/TickLogo.dart';
import '../theme/app_theme.dart';

class WelcomePage1 extends StatelessWidget {
  const WelcomePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // TaskSync Logo
                const Center(
                  child: TickLogoLarge(
                    size: 80,
                    tickColor: Colors.white,
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // App Name
                Text(
                  'TaskSync',
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Main Heading
                Text(
                  'Manage your projects in a smarter way',
                  textAlign: TextAlign.center,
                  style: AppTheme.headingMedium.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Subheading
                Text(
                  'Improve your team efficiency with powerful project management tools',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Features List
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    children: [
                      _buildFeatureItem(Icons.task_alt, 'Task Management'),
                      const SizedBox(height: 10),
                      _buildFeatureItem(Icons.people, 'Team Collaboration'),
                      const SizedBox(height: 10),
                      _buildFeatureItem(Icons.schedule, 'Smart Scheduling'),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Get Started Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 32),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomePage2()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: AppTheme.buttonText.copyWith(
                            color: AppTheme.primaryBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
