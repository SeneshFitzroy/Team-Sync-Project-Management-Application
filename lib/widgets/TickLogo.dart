import 'package:flutter/material.dart';

class TickLogo extends StatelessWidget {
  final double size;
  final Color color;
  final Color backgroundColor;
  final bool showBackground;

  const TickLogo({
    super.key,
    this.size = 60,
    this.color = Colors.white,
    this.backgroundColor = const Color(0xFF2D62ED),
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBackground
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(size * 0.2),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Center(
        child: Icon(
          Icons.check,
          size: size * 0.6,
          color: color,
          weight: 900,
        ),
      ),
    );
  }
}

class TickLogoLarge extends StatelessWidget {
  final double size;
  final Color tickColor;
  final Color backgroundColor;

  const TickLogoLarge({
    super.key,
    this.size = 200,
    this.tickColor = Colors.white,
    this.backgroundColor = const Color(0xFF2D62ED),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.15),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.check,
          size: size * 0.5,
          color: tickColor,
          weight: 900,
        ),
      ),
    );
  }
}
