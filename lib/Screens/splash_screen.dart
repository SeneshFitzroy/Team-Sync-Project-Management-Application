import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';
import 'welcome-page1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
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
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
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
    // Start logo animation
    _logoController.forward();
    
    // Wait a bit, then start text animation
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    
    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
    
    // Wait for animations to complete, then navigate (reduced time)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WelcomePage1(),
        ),
      );
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
      body: SafeArea(
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
                return SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(_safeOpacity(_textFadeAnimation.value)),
                    child: Column(
                      children: [
                        // App Name with animated icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _progressAnimation.value * 2 * 3.14159,
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
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Subtitle with decorative lines
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDecorativeLine(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'PROJECT MANAGEMENT',
                                style: AppTheme.bodySmall.copyWith(
                                  fontSize: 13,
                                  letterSpacing: 2.0,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildDecorativeLine(),
                          ],
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
                return Column(
                  children: [
                    // Loading text
                    FadeTransition(
                      opacity: AlwaysStoppedAnimation(_safeOpacity(_textFadeAnimation.value)),
                      child: Text(
                        'Loading...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Animated progress bar
                    Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 200 * _progressAnimation.value,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue,
                                  AppTheme.primaryLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Percentage text
                    Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const Spacer(),
            
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FadeTransition(
                opacity: AlwaysStoppedAnimation(_safeOpacity(_textFadeAnimation.value)),
                child: Column(
                  children: [
                    Text(
                      'Streamline Your Workflow',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          width: 40 * _progressAnimation.value,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.primaryBlue,
                AppTheme.primaryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
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
