import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo or illustration would go here
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  size: 80,
                  color: AppTheme.primaryBlue,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Main title
              Text(
                'Improve your team efficiency',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Manage your projects in a smartest way',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.grayText,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Let's start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/welcome');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Let's start!"),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
