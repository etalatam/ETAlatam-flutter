import 'package:flutter/material.dart';

class Loader extends StatefulWidget {
  final String? message;
  final Color? backgroundColor;

  const Loader({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for the main spinner
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Scale animation for the pulsing effect
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for the dots
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? Colors.white.withOpacity(0.95),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern circular loader with gradient
            AnimatedBuilder(
              animation: Listenable.merge([
                _rotationAnimation,
                _scaleAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Color(0xFF4A90E2),
                            Color(0xFF357ABD),
                            Color(0xFF4A90E2).withOpacity(0.5),
                            Color(0xFF4A90E2).withOpacity(0.1),
                            Color(0xFF4A90E2),
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.backgroundColor ?? Colors.white,
                          ),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF4A90E2).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // Animated dots indicator
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final opacity = (_fadeAnimation.value + delay) % 1.0;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4A90E2).withOpacity(
                          opacity.clamp(0.3, 1.0),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            // Optional message
            if (widget.message != null) ...[
              SizedBox(height: 20),
              Text(
                widget.message!,
                style: TextStyle(
                  color: Color(0xFF1E3050),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Alternative minimal loader for inline use
class InlineLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const InlineLoader({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  _InlineLoaderState createState() => _InlineLoaderState();
}

class _InlineLoaderState extends State<InlineLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.color ?? Color(0xFF4A90E2),
              ),
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }
}