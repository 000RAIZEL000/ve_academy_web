import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CelebrationOverlay extends StatefulWidget {
  final String message;
  final int stars;
  final VoidCallback onComplete;

  const CelebrationOverlay({
    super.key,
    required this.message,
    required this.stars,
    required this.onComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _starCtrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  final List<_Confetti> _confetti = [];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    for (int i = 0; i < 24; i++) {
      _confetti.add(_Confetti(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        color: [
          const Color(0xFFFFD700),
          const Color(0xFFFF6B9D),
          const Color(0xFF4FC3F7),
          const Color(0xFF81C784),
          const Color(0xFFFFB74D),
          const Color(0xFFCE93D8),
        ][rng.nextInt(6)],
        size: 8.0 + rng.nextDouble() * 10,
        rotation: rng.nextDouble() * 2 * pi,
      ));
    }

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
    ]).animate(_ctrl);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        return Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Stack(
            children: [
              // Dark overlay
              Container(color: Colors.black.withAlpha(160)),
              // Confetti
              ..._confetti.map((c) => Positioned(
                    left: MediaQuery.of(ctx).size.width * c.x,
                    top: MediaQuery.of(ctx).size.height * c.y +
                        _ctrl.value * 60 * c.fallSpeed,
                    child: Transform.rotate(
                      angle: c.rotation + _ctrl.value * pi,
                      child: Container(
                        width: c.size,
                        height: c.size,
                        decoration: BoxDecoration(
                          color: c.color.withAlpha(200),
                          borderRadius: BorderRadius.circular(c.size * 0.2),
                        ),
                      ),
                    ),
                  )),
              // Card
              Center(
                child: Transform.scale(
                  scale: _scale.value.clamp(0.0, 2.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C3DE0), Color(0xFFE040A0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C3DE0).withAlpha(120),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stars
                        AnimatedBuilder(
                          animation: _starCtrl,
                          builder: (ctx, _) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(widget.stars, (i) {
                              final delay = i * 0.15;
                              final pulse = sin(
                                      (_starCtrl.value + delay) * pi)
                                  .abs();
                              return Transform.scale(
                                scale: 1.0 + 0.2 * pulse,
                                child: const Text(
                                  '⭐',
                                  style: TextStyle(fontSize: 40),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Muy bien!',
                          style: GoogleFonts.baloo2(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.message,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.white.withAlpha(220),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Confetti {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double rotation;
  final double fallSpeed;

  _Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
  }) : fallSpeed = 0.5 + Random().nextDouble();
}
