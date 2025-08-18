import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';
import 'simple_welcome_page.dart';

class CleanSplashScreen extends StatefulWidget {
  const CleanSplashScreen({super.key});

  @override
  State<CleanSplashScreen> createState() => _CleanSplashScreenState();
}

class _CleanSplashScreenState extends State<CleanSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  // Helper method to safely clamp opacity values
  double _safeOpacity(double value) {
    return value.clamp(0.0, 1.0);
  }

  // Helper method to safely clamp scale values
  double _safeScale(double value) {
    return value.clamp(0.0, double.infinity);
  }

  @override
  void initState() {
    super.initState();
    print('CleanSplashScreen: initState called');
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    print('CleanSplashScreen: Animation sequence started');
    
    // Start all animations together for faster loading
    _logoController.forward();
    _textController.forward();
    _progressController.forward();
    
    print('CleanSplashScreen: All animations started');
    
    // Navigate after 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));
    print('CleanSplashScreen: About to navigate');
    
    if (mounted) {
      print('CleanSplashScreen: Widget is mounted, navigating to SimpleWelcomePage');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleWelcomePage(),
        ),
      );
    } else {
      print('CleanSplashScreen: Widget not mounted, cannot navigate');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: GestureDetector(
        onTap: () {
          print('CleanSplashScreen: Tapped, navigating immediately');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SimpleWelcomePage(),
            ),
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              
              // Animated Logo Section
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(_safeOpacity(_logoFadeAnimation.value)),
                    child: ScaleTransition(
                      scale: AlwaysStoppedAnimation(_safeScale(_logoScaleAnimation.value)),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                              spreadRadius: 10,
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const TickLogoLarge(
                          size: 120,
                          tickColor: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.backgroundLight,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Animated Text Section
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(_safeOpacity(_textFadeAnimation.value)),
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Team Sync',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Project Management',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 2),
              
              // Animated Progress Section
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: AlwaysStoppedAnimation(_safeOpacity(_progressAnimation.value)),
                    child: Column(
                      children: [
                        Container(
                          width: 200,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryBlue,
                                    AppTheme.primaryLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 1),
              
              // Footer with dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFooterDot(),
                  const SizedBox(width: 8),
                  _buildFooterDot(),
                  const SizedBox(width: 8),
                  _buildFooterDot(),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Tap hint
              FadeTransition(
                opacity: AlwaysStoppedAnimation(_safeOpacity(_progressAnimation.value * 0.7)),
                child: const Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterDot() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(
              alpha: _safeOpacity(0.3 + (0.7 * _progressAnimation.value)),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
