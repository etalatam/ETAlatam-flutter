import 'package:flutter/material.dart';

class AnimatedSnackBarContent extends StatefulWidget {
  
  String? title;

  AnimatedSnackBarContent({super.key, this.title});

  @override
  _AnimatedSnackBarContentState createState() => _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Configura el AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Duración de la animación
    )..repeat(reverse: true); // Repite la animación en bucle

    // Configura la animación de opacidad
    _opacityAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera el controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value, // Aplica la opacidad animada
          child: Container(
            height: 60.0,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 234, 241, 245),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                widget.title!,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}