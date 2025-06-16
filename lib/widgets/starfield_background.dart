import 'dart:math';
import 'package:flutter/material.dart';

class Star {
  double x, y, z;
  Star(this.x, this.y, this.z);
}

class StarfieldBackground extends StatefulWidget {
  const StarfieldBackground({Key? key}) : super(key: key);

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  final int _starCount = 400;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // Slower scroll
    )..repeat();
    _stars = List.generate(_starCount, (index) {
      return Star(
        Random().nextDouble(),
        Random().nextDouble(),
        Random().nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarfieldPainter(_stars, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final List<Star> stars;
  final double value;

  StarfieldPainter(this.stars, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF000011), Color(0xFF0D1A3F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.8);

    for (var star in stars) {
      final y = (star.y + value * 0.1 * (1 + star.z)) % 1.0;
      final x = star.x;

      final radius = (1 + star.z) * 0.7; // Depth perception

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        radius,
        starPaint..color = Colors.white.withOpacity(star.z),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 