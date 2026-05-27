import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.4)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    await _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final session = await SessionService.getSession();
      if (!mounted) return;
      if (session != null) {
        try {
          final api = ApiService();
          final data = await api.verifyToken(session['token'] as String);
          final localPuntos = (session['puntos'] as num?)?.toInt() ?? 0;
          final serverPuntos = (data['puntos'] as num?)?.toInt() ?? 0;
          final mejorPuntos = localPuntos > serverPuntos ? localPuntos : serverPuntos;
          final safeData = Map<String, dynamic>.from(data)..['puntos'] = mejorPuntos;
          await SessionService.saveSession(safeData);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home', arguments: safeData);
          return;
        } catch (_) {
          await SessionService.clearSession();
        }
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteSplash),
        child: Stack(
          children: [
            // Círculos decorativos de fondo
            ..._buildDecorativeCircles(),
            // Contenido centrado
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animado
                  ScaleTransition(
                    scale: _pulse,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: _buildLogo(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Texto animado
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'V&E Academy',
                            style: GoogleFonts.baloo2(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: AppColors.rosaOscuro,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '✨ Aprende leyendo y jugando ✨',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lilaOscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 64),
                  // Loader de puntos
                  FadeTransition(
                    opacity: _textOpacity,
                    child: const _DotLoader(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const AppLogo(size: 160, withShadow: true);
  }

  List<Widget> _buildDecorativeCircles() {
    return [
      _circle(top: -60, left: -60, size: 200, color: AppColors.rosa.withOpacity(0.18)),
      _circle(bottom: -80, right: -40, size: 250, color: AppColors.lila.withOpacity(0.15)),
      _circle(top: 100, right: -30, size: 120, color: AppColors.celeste.withOpacity(0.2)),
      _circle(bottom: 120, left: -20, size: 100, color: AppColors.amarillo.withOpacity(0.25)),
      _circle(top: 200, left: 40, size: 60, color: AppColors.rosa.withOpacity(0.12)),
    ];
  }

  Widget _circle({
    double? top, double? bottom, double? left, double? right,
    required double size, required Color color,
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _DotLoader extends StatefulWidget {
  const _DotLoader();

  @override
  State<_DotLoader> createState() => _DotLoaderState();
}

class _DotLoaderState extends State<_DotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final t = (_ctrl.value - delay).clamp(0.0, 1.0);
          final scale = 0.5 + 0.5 * (1 - (2 * t - 1).abs());
          final colors = [AppColors.rosa, AppColors.lila, AppColors.celeste];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
