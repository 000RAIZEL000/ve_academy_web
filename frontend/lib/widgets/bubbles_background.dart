import 'dart:math';
import 'package:flutter/material.dart';

class BubblesBackground extends StatefulWidget {
  final Widget child;
  const BubblesBackground({super.key, required this.child});

  @override
  State<BubblesBackground> createState() => _BubblesBackgroundState();
}

class _BubblesBackgroundState extends State<BubblesBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_BubbleConfig> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Creates an infinite loop of 20 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _initializeBubbles();
  }

  void _initializeBubbles() {
    // Colors matching the CSS configuration
    final colors = [
      const Color(0xFF2ecc71), // verde
      const Color(0xFF3498db), // azul
      const Color(0xFFf39c12), // naranja
      const Color(0xFF9b59b6), // morado
      const Color(0xFFf1c40f), // amarillo
      const Color(0xFFe91e8c), // rosa
      const Color(0xFFe74c3c), // rojo
    ];

    for (int i = 0; i < 10; i++) {
      _bubbles.add(
        _BubbleConfig(
          size: _random.nextDouble() * 50 + 25, // 25 to 75
          xPosition: _random.nextDouble(), // 0.0 to 1.0 (relative to width)
          color: colors[i % colors.length],
          durationMultiplier: _random.nextDouble() * 0.5 + 0.5, // 0.5 to 1.0 speed
          startDelay: _random.nextDouble(), // 0.0 to 1.0 offset
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color
        Container(color: const Color(0xFFfef9f0)),
        // Bubbles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _BubblePainter(
                bubbles: _bubbles,
                progress: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Foreground content
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _BubbleConfig {
  final double size;
  final double xPosition;
  final Color color;
  final double durationMultiplier;
  final double startDelay;

  _BubbleConfig({
    required this.size,
    required this.xPosition,
    required this.color,
    required this.durationMultiplier,
    required this.startDelay,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_BubbleConfig> bubbles;
  final double progress;

  _BubblePainter({required this.bubbles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = bubble.color.withOpacity(0.18)
        ..style = PaintingStyle.fill;

      // Calculate vertical position
      // Loop seamlessly using modulo
      double currentProgress = (progress * bubble.durationMultiplier + bubble.startDelay) % 1.0;
      
      // Start slightly below screen, end slightly above
      double startY = size.height + bubble.size;
      double endY = -bubble.size;
      double currentY = startY - (startY - endY) * currentProgress;

      double currentX = bubble.xPosition * size.width;

      // Add a slight rotation/wobble effect using sine wave
      double wobble = sin(currentProgress * pi * 4) * 20;

      canvas.drawCircle(Offset(currentX + wobble, currentY), bubble.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return true; // Always repaint as it's driven by animation tick
  }
}
