import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'TickLogo.dart';

class ConsistentHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final double logoSize;
  final bool showParticles;
  final bool showDecorative;

  const ConsistentHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.logoSize = 100,
    this.showParticles = true,
    this.showDecorative = true,
  });

  @override
  State<ConsistentHeader> createState() => _ConsistentHeaderState();
}

class _ConsistentHeaderState extends State<ConsistentHeader>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  void _startAnimations() async {
    if (widget.showParticles) {
      _particleController.repeat();
    }
    
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background particles (optional)
        if (widget.showParticles)
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: HeaderParticlePainter(_particleAnimation.value),
                size: Size(MediaQuery.of(context).size.width, 300),
              );
            },
          ),
        
        // Main header content
        Column(
          children: [
            // Consistent Logo Design (blue-purple gradient ball with tick)
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                        spreadRadius: 15,
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                      size: widget.logoSize,
                      color: Colors.white,
                      backgroundColor: Colors.transparent,
                      showBackground: false,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title with gradient text
            FadeTransition(
              opacity: _fadeAnimation,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      AppTheme.primaryBlue,
                      Color(0xFF764BA2),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  widget.title,
                  style: AppTheme.headingLarge.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Subtitle with decorative elements (optional)
            if (widget.subtitle != null) ...[
              const SizedBox(height: 12),
              
              FadeTransition(
                opacity: _fadeAnimation,
                child: widget.showDecorative
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDecorativeLine(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              widget.subtitle!,
                              style: AppTheme.bodyMedium.copyWith(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          _buildDecorativeLine(),
                        ],
                      )
                    : Text(
                        widget.subtitle!,
                        style: AppTheme.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDecorativeLine() {
    return Container(
      width: 30,
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
}

// Custom painter for header particles
class HeaderParticlePainter extends CustomPainter {
  final double animationValue;
  
  HeaderParticlePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Generate consistent particles for header area
    final random = Random(24); // Different seed for header
    
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + (random.nextDouble() * 2.0);
      
      // Animate opacity and position
      final opacity = (0.03 + (random.nextDouble() * 0.15)) * 
                     (0.5 + 0.5 * sin(animationValue * 2 * pi + i));
      final offsetY = sin(animationValue * 2 * pi + i * 0.5) * 6;
      
      paint.color = AppTheme.primaryBlue.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y + offsetY),
        radius,
        paint,
      );
    }
    
    // Add some smaller particles
    for (int i = 0; i < 4; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.8 + (random.nextDouble() * 1.5);
      
      final opacity = (0.02 + (random.nextDouble() * 0.08)) * 
                     (0.3 + 0.7 * sin(animationValue * pi + i * 0.3));
      final offsetY = cos(animationValue * pi + i * 0.7) * 8;
      final offsetX = sin(animationValue * 0.5 * pi + i * 0.4) * 3;
      
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
