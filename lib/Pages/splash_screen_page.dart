import 'dart:async';

import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/gets_started.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
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
      curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    // Text animations
    _textController = AnimationController(
      duration: Duration(milliseconds: 800),
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
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Progress bar animation
    _progressController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Shimmer effect animation
    _shimmerController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }

  void _startAnimationSequence() async {
    // Start logo animation
    await Future.delayed(Duration(milliseconds: 200));
    _logoController.forward();

    // Start text animation after logo
    await Future.delayed(Duration(milliseconds: 600));
    _textController.forward();

    // Start progress animation
    await Future.delayed(Duration(milliseconds: 300));
    _progressController.forward();

    // Check login status while animations play
    await Future.delayed(Duration(milliseconds: 1000));
    logInCheck();
  }

  logInCheck() async {
    final check = await storage.getItem('token');
    if (check != null) {
      // Navigate with fade transition
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    } else {
      final started = await preferences.getBool('started');
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              started != null ? Login() : GetStartedApp(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3050),
              Color(0xFF2A4570),
              Color(0xFF3A5590),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BackgroundPatternPainter(
                      shimmerPosition: _shimmerAnimation.value,
                    ),
                  );
                },
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Spacer(flex: 3),

                  // Logo with animations
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 40,
                              offset: Offset(0, 10),
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(25),
                        child: Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            "assets/logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Spacer(flex: 2),

                  // Animated progress indicator
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.white,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Loading text removed - simplifying splash screen

                  Spacer(flex: 1),

                  // Version info
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Versión 1.12.40',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final double shimmerPosition;

  BackgroundPatternPainter({required this.shimmerPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw animated circles
    for (int i = 0; i < 5; i++) {
      final progress = (shimmerPosition + i * 0.2).clamp(0.0, 1.0);
      final opacity = (1.0 - progress).clamp(0.0, 0.1);

      paint.color = Colors.white.withOpacity(opacity);

      final center = Offset(
        size.width * (0.2 + i * 0.2),
        size.height * (0.3 + i * 0.1),
      );

      final radius = size.width * 0.3 * (1 + progress);

      canvas.drawCircle(center, radius, paint);
    }

    // Draw gradient overlay
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return oldDelegate.shimmerPosition != shimmerPosition;
  }
}