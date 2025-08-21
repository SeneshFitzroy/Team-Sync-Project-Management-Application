import 'package:flutter/material.dart';
import 'welcome-page2.dart';
import '../widgets/TickLogo.dart';
import '../theme/app_theme.dart';

class WelcomePage1 extends StatefulWidget {
  const WelcomePage1({super.key});

  @override
  State<WelcomePage1> createState() => _WelcomePage1State();
}

class _WelcomePage1State extends State<WelcomePage1>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _floatingController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
              
              // Animated Logo Section
              AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              spreadRadius: 8,
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value * 10 - 5),
                              child: const TickLogoLarge(
                                size: 100,
                                tickColor: AppTheme.primaryBlue,
                                backgroundColor: AppTheme.backgroundLight,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Animated App Name
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _floatingController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _floatingAnimation.value * 0.1,
                            child: const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryBlue,
                              size: 32,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'TaskSync',
                        style: AppTheme.headingLarge.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Animated Main Heading
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Manage your projects in a smarter way',
                        textAlign: TextAlign.center,
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Improve your team efficiency with powerful project management tools',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Animated Feature List
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        children: [
                          _buildAnimatedFeatureItem(Icons.task_alt, 'Task Management', 0),
                          const SizedBox(height: 24),
                          _buildAnimatedFeatureItem(Icons.people, 'Team Collaboration', 300),
                          const SizedBox(height: 24),
                          _buildAnimatedFeatureItem(Icons.schedule, 'Smart Scheduling', 600),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Animated Get Started Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 40),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _scaleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage2(),
                                    transitionDuration: const Duration(milliseconds: 500),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: AppTheme.buttonText.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedBuilder(
                                    animation: _floatingController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(_floatingAnimation.value * 4, 0),
                                        child: const Icon(
                                          Icons.arrow_forward,
                                          color: AppTheme.textWhite,
                                          size: 20,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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

  Widget _buildAnimatedFeatureItem(IconData icon, String text, int delay) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1000 + delay),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 30),
              child: Opacity(
                opacity: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          text,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
