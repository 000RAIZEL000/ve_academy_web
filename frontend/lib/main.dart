import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/session_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VeAcademyApp());
}

class VeAcademyApp extends StatelessWidget {
  const VeAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V&E Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.verde,
          primary: AppColors.verde,
          secondary: AppColors.naranja,
          surface: AppColors.fondo,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData().textTheme).copyWith(
          displayLarge: GoogleFonts.baloo2(
              color: AppColors.texto, fontWeight: FontWeight.w800),
          displayMedium: GoogleFonts.baloo2(
              color: AppColors.texto, fontWeight: FontWeight.w800),
          titleLarge: GoogleFonts.baloo2(
              color: AppColors.texto, fontWeight: FontWeight.w700),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black26,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.fondo,
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────── Splash Screen ───────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo: elastic pop-in
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Text + loading: fade + slide up
  late AnimationController _textCtrl;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;

  // Rings: pulsing glow
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_logoCtrl);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _logoCtrl.forward();
    await _textCtrl.forward();
    // Wait a bit before checking session
    await Future.delayed(const Duration(milliseconds: 700));
    await _checkSession();
  }

  Future<void> _checkSession() async {
    final session = await SessionService.getSession();
    if (!mounted) return;

    if (session == null) {
      _goTo(const LoginScreen());
      return;
    }

    try {
      final estudiante =
          await ApiService().verifyToken(session['token'] as String);
      await SessionService.saveSession(estudiante);
      if (!mounted) return;
      _goTo(HomeScreen(
        estudianteId: estudiante['id'] as int,
        estudianteEdad: estudiante['edad'] as int,
      ));
    } catch (_) {
      await SessionService.clearSession();
      if (!mounted) return;
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => screen,
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Pulsing rings behind logo
            Center(
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (ctx, _) {
                  final r = 80.0 + _glowCtrl.value * 30;
                  final opacity = 0.06 + _glowCtrl.value * 0.04;
                  return CustomPaint(
                    painter: _RingPainter(r, opacity),
                  );
                },
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (ctx, child) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C3DE0), Color(0xFFE040A0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C3DE0).withAlpha(120),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎓', style: TextStyle(fontSize: 64)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Title + subtitle
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (ctx, child) => Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: child,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'V&E Academy',
                          style: GoogleFonts.baloo2(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Aprende leyendo! 📚',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.white60,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Dot loader
                        const _DotLoader(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom version text
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textCtrl,
                builder: (ctx, child) =>
                    Opacity(opacity: _textOpacity.value, child: child),
                child: const Text(
                  'v1.0 · Para niños de 5 a 7 años',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
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
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
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
      builder: (ctx, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final offset = Tween<double>(begin: 0, end: -10).animate(
              CurvedAnimation(
                parent: _ctrl,
                curve: Interval(
                  i * 0.2,
                  0.6 + i * 0.2,
                  curve: Curves.easeInOut,
                ),
              ),
            );
            return Transform.translate(
              offset: Offset(0, offset.value),
              child: Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i == 0
                      ? const Color(0xFF6C3DE0)
                      : i == 1
                          ? const Color(0xFFE040A0)
                          : AppColors.verde,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double radius;
  final double opacity;

  _RingPainter(this.radius, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withAlpha((opacity * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 1.5, paint.copyWith()
      ..color = Colors.white.withAlpha((opacity * 0.5 * 255).round()));
    canvas.drawCircle(center, radius * 2.1, paint.copyWith()
      ..color = Colors.white.withAlpha((opacity * 0.25 * 255).round()));
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.radius != radius || old.opacity != opacity;
}

extension _PaintCopy on Paint {
  Paint copyWith() => Paint()
    ..color = color
    ..style = style
    ..strokeWidth = strokeWidth;
}
