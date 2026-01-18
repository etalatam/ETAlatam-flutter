import 'package:flutter/material.dart';

/// Widget que proporciona un layout responsive para iPad y iPhone
/// En iPad, centra el contenido y agrega márgenes laterales
/// En iPhone, usa el ancho completo
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveLayout({
    Key? key,
    required this.child,
    this.maxWidth = 800, // Ancho máximo para iPad
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600; // iPad threshold

    if (!isTablet) {
      // iPhone - usar ancho completo
      return child;
    }

    // iPad - centrar con márgenes laterales
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 40),
        child: child,
      ),
    );
  }
}

/// Widget para contenido de scroll con márgenes en iPad
class ResponsiveScrollView extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const ResponsiveScrollView({
    Key? key,
    required this.children,
    this.maxWidth = 800,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    if (!isTablet) {
      // iPhone - usar ancho completo
      return SingleChildScrollView(
        physics: physics,
        scrollDirection: scrollDirection,
        child: Column(
          children: children,
        ),
      );
    }

    // iPad - centrar con márgenes laterales
    return SingleChildScrollView(
      physics: physics,
      scrollDirection: scrollDirection,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: padding ?? EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}

/// Obtiene el padding horizontal apropiado según el dispositivo
EdgeInsetsGeometry getResponsivePadding(BuildContext context, {
  double phonePadding = 16.0,
  double tabletPadding = 40.0,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth >= 600;

  return EdgeInsets.symmetric(
    horizontal: isTablet ? tabletPadding : phonePadding,
  );
}

/// Obtiene el ancho máximo para contenido centrado
double getMaxContentWidth(BuildContext context, {double maxWidth = 800}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth >= 600;

  return isTablet ? maxWidth : screenWidth;
}

/// Verifica si el dispositivo es tablet
bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >= 600;
}
