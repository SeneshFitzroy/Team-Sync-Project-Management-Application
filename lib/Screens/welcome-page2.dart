import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'create_account_new.dart';
import 'login-page.dart';
import '../widgets/TickLogo.dart';
import '../theme/app_theme.dart';

class WelcomePage2 extends StatefulWidget {
  const WelcomePage2({super.key});

  @override
  State<WelcomePage2> createState() => _WelcomePage2State();
}

class _WelcomePage2State extends State<WelcomePage2>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _buttonController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
  }

  void _startAnimationSequence() async {
    HapticFeedback.lightImpact();

    // Start particle animation (continuous)
    _particleController.repeat();

    // Stagger the animations
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _buttonController.dispose();
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
              // Animated background particles (consistent with other pages)
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Consistent Logo Design (blue-purple gradient ball with tick)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
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
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                spreadRadius: 20,
                                blurRadius: 40,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(28),
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
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const TickLogo(
                              size: 120,
                              color: Colors.white,
                              backgroundColor: Colors.transparent,
                              showBackground: false,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Animated App Name with consistent styling
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
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
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1.0,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),

                            // Subtitle with decorative elements (consistent design)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildDecorativeLine(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'PROJECT MANAGEMENT',
                                    style: AppTheme.bodySmall.copyWith(
                                      fontSize: 12,
                                      letterSpacing: 2.5,
                                      color: AppTheme.textSecondary.withOpacity(0.8),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                _buildDecorativeLine(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Enhanced Buttons with consistent styling
                    AnimatedBuilder(
                      animation: _buttonController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Log in button with gradient design
                            _buildModernButton(
                              context,
                              text: 'Log in',
                              isPrimary: true,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const LoginPage(),
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
                                    transitionDuration: const Duration(milliseconds: 600),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Create account button with outlined style
                            _buildModernButton(
                              context,
                              text: 'Create account',
                              isPrimary: false,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const CreateAccount(),
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
                                    transitionDuration: const Duration(milliseconds: 600),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build decorative lines (consistent design)
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

  Widget _buildModernButton(
    BuildContext context, {
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: isPrimary ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF764BA2),
          ],
        ) : null,
        color: isPrimary ? null : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isPrimary ? null : Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary 
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: isPrimary ? 15 : 8,
            offset: Offset(0, isPrimary ? 8 : 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Text(
              text,
              style: AppTheme.bodyLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppTheme.primaryBlue,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for animated background particles (consistent across all pages)
class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Generate consistent particles based on screen size
    final random = Random(42); // Fixed seed for consistent positions
    
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + (random.nextDouble() * 2.5);
      
      // Animate opacity and position
      final opacity = (0.05 + (random.nextDouble() * 0.2)) * 
                     (0.5 + 0.5 * sin(animationValue * 2 * pi + i));
      final offsetY = sin(animationValue * 2 * pi + i * 0.5) * 8;
      
      paint.color = AppTheme.primaryBlue.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y + offsetY),
        radius,
        paint,
      );
    }
    
    // Add some larger, slower moving particles
    for (int i = 0; i < 6; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.5 + (random.nextDouble() * 3);
      
      final opacity = (0.03 + (random.nextDouble() * 0.1)) * 
                     (0.3 + 0.7 * sin(animationValue * pi + i * 0.3));
      final offsetY = cos(animationValue * pi + i * 0.7) * 12;
      final offsetX = sin(animationValue * 0.5 * pi + i * 0.4) * 4;
      
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