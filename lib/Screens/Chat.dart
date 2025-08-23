import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';
import './Profile.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _fadeController.forward();
    _slideController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particle background
            AnimatedBuilder(
              animation: _particleAnimation,
              child: Container(),
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildHeader(),
                    ),
                  ),
                  
                  // Chat content
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildChatContent(),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        TickLogo(size: 35),
        SizedBox(width: 12),
        Text(
          'Team Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatContent() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Feature icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue.withOpacity(0.1), Color(0xFF764BA2).withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_outlined,
              size: 60,
              color: AppTheme.primaryBlue,
            ),
          ),
          
          SizedBox(height: 30),
          
          // Title
          Text(
            'Team Chat Feature',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16),
          
          // Description
          Text(
            'Real-time messaging and collaboration tools are coming soon! Stay tuned for updates.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 30),
          
          // Features preview
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Coming Features:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 12),
                _buildFeatureItem('Real-time messaging', Icons.message_outlined),
                _buildFeatureItem('File sharing', Icons.attach_file_outlined),
                _buildFeatureItem('Voice messages', Icons.mic_outlined),
                _buildFeatureItem('Team channels', Icons.group_outlined),
              ],
            ),
          ),
          
          SizedBox(height: 30),
          
          // Notification button
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.notifications_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text('You\'ll be notified when chat feature is available!'),
                      ],
                    ),
                    backgroundColor: AppTheme.primaryBlue,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Notify Me When Ready',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Particle painter for background animation
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 2.0;

    for (int i = 0; i < 40; i++) {
      final x = (i * 47.0 + animationValue * 60) % size.width;
      final y = (i * 53.0 + animationValue * 40) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
