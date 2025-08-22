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
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Main controller for overall timing
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _logoGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Particle effect
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    // Background animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Start background animation
    _mainController.forward();
    
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();
    
    // Start particle animation
    _particleController.repeat();
    
    // Wait for completion, then navigate
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage1(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
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
        decoration: BoxDecoration(
          gradient: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFFF8FAFC), const Color(0xFF667EEA), _backgroundAnimation.value * 0.1) ?? const Color(0xFFF8FAFC),
                  Color.lerp(Colors.white, const Color(0xFF764BA2), _backgroundAnimation.value * 0.05) ?? Colors.white,
                  Color.lerp(const Color(0xFFF1F5F9), const Color(0xFF667EEA), _backgroundAnimation.value * 0.08) ?? const Color(0xFFF1F5F9),
                ],
                stops: const [0.0, 0.5, 1.0],
              );
            },
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
                              child: const Icon(
                                Icons.check_circle_outline,
                                size: 80,
                                color: Colors.white,
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
                      opacity: _textFadeAnimation,
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
                                  color: AppTheme.primaryBlue.withOpacity(0.4),
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
                opacity: _textFadeAnimation,
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
            color: AppTheme.primaryBlue.withOpacity(
              0.3 + (0.7 * _progressAnimation.value),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
