import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Main controller for overall sequence
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Particle animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
  }

  void _startAnimationSequence() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Start particle animation (continuous)
    _particleController.repeat();

    // Start main background animation
    _mainController.forward();

    // Delay then start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    HapticFeedback.selectionClick();

    // Delay then start text animation
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Delay then start progress animation
    await Future.delayed(const Duration(milliseconds: 800));
    _progressController.forward();

    // Wait for all animations to complete, then navigate
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      HapticFeedback.heavyImpact();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const WelcomePage1(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Colors.white,
              Color(0xFFF1F5F9),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background particles
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlePainter(_particleAnimation.value),
                    size: MediaQuery.of(context).size,
                  );
                },
              ),
              
              // Main content
              Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Animated Logo Section
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotateAnimation.value * 0.1,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.primaryBlue.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3 * _logoGlowAnimation.value),
                                  spreadRadius: 20 * _logoGlowAnimation.value,
                                  blurRadius: 40 * _logoGlowAnimation.value,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryBlue,
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: TickLogo(
                                size: 80,
                                color: Colors.white,
                                backgroundColor: Colors.transparent,
                                showBackground: false,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Animated Text Section
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              // App Name with gradient text
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return const LinearGradient(
                                    colors: [
                                      AppTheme.primaryBlue,
                                      Color(0xFF764BA2),
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'TaskSync',
                                  style: AppTheme.headingLarge.copyWith(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1.5,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Subtitle with animated decorative elements
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDecorativeLine(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(
                                      'PROJECT MANAGEMENT',
                                      style: AppTheme.bodySmall.copyWith(
                                        fontSize: 14,
                                        letterSpacing: 3.0,
                                        color: AppTheme.textSecondary.withOpacity(0.8),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _buildDecorativeLine(),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Tagline
                              Text(
                                'Streamline • Collaborate • Achieve',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Modern Progress Section
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Column(
                        children: [
                          // Loading text with subtle animation
                          FadeTransition(
                            opacity: _textFadeAnimation,
                            child: Text(
                              'Initializing workspace...',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Modern progress indicator
                          Container(
                            width: 280,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                // Background track
                                Container(
                                  width: 280,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                // Progress fill
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: 280 * _progressAnimation.value,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.primaryBlue,
                                        Color(0xFF764BA2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withOpacity(0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                // Shimmer effect
                                if (_progressAnimation.value > 0)
                                  Positioned(
                                    left: (280 * _progressAnimation.value) - 30,
                                    child: Container(
                                      width: 30,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white.withOpacity(0.5),
                                            Colors.white.withOpacity(0.0),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Percentage with animated counter
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 100),
                            tween: Tween(begin: 0, end: _progressAnimation.value * 100),
                            builder: (context, value, child) {
                              return Text(
                                '${value.toInt()}%',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Enhanced Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Built with ❤️ for productivity',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textLight.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFooterDot(0),
                              const SizedBox(width: 12),
                              _buildFooterDot(1),
                              const SizedBox(width: 12),
                              _buildFooterDot(2),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to build decorative lines
  Widget _buildDecorativeLine() {
    return Container(
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.primaryBlue,
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
  
  // Helper method to build footer dots
  Widget _buildFooterDot(int index) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        double animationValue = (_progressAnimation.value * 3 - index).clamp(0.0, 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryBlue.withOpacity(0.3 + (0.7 * animationValue)),
            boxShadow: animationValue > 0.5 ? [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
        );
      },
    );
  }
}

// Custom painter for animated background particles
class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Generate consistent particles based on screen size
    final random = Random(42); // Fixed seed for consistent positions
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.5 + (random.nextDouble() * 3);
      
      // Animate opacity and position
      final opacity = (0.1 + (random.nextDouble() * 0.3)) * 
                     (0.5 + 0.5 * sin(animationValue * 2 * pi + i));
      final offsetY = sin(animationValue * 2 * pi + i * 0.5) * 10;
      
      paint.color = AppTheme.primaryBlue.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y + offsetY),
        radius,
        paint,
      );
    }
    
    // Add some larger, slower moving particles
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 2.0 + (random.nextDouble() * 4);
      
      final opacity = ((0.05 + (random.nextDouble() * 0.15)) * 
                     (0.3 + 0.7 * sin(animationValue * pi + i * 0.3))).clamp(0.0, 1.0);
      final offsetY = cos(animationValue * pi + i * 0.7) * 15;
      final offsetX = sin(animationValue * 0.5 * pi + i * 0.4) * 5;
      
      paint.color = const Color(0xFF764BA2).withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
