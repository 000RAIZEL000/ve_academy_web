import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_step1_screen.dart';
import 'screens/register_step2_screen.dart';
import 'widgets/main_scaffold.dart';

void main() {
  runApp(const VeAcademyApp());
}

class VeAcademyApp extends StatelessWidget {
  const VeAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V&E Academy',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fade(const SplashScreen());
      case '/login':
        return _fade(const LoginScreen());
      case '/register/step1':
        return _slide(const RegisterStep1Screen());
      case '/register/step2':
        final data = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(RegisterStep2Screen(step1Data: data));
      case '/home':
        final session = settings.arguments as Map<String, dynamic>? ?? {};
        return _fade(MainScaffold(session: session));
      default:
        return _fade(const SplashScreen());
    }
  }

  PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      );

  PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rosa,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.rosaOscuro,
        secondary: AppColors.lilaOscuro,
        surface: AppColors.blanco,
      ),
      scaffoldBackgroundColor: AppColors.fondo,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.baloo2(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.texto),
        displayMedium: GoogleFonts.baloo2(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.texto),
        headlineLarge: GoogleFonts.baloo2(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.texto),
        headlineMedium: GoogleFonts.baloo2(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.texto),
        titleLarge: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.texto),
        bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.texto),
        bodyMedium: GoogleFonts.nunito(
            fontSize: 14, color: AppColors.textoSuave),
        labelLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.texto),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.fondoTarjeta,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lila, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lila, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.lilaOscuro, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.errorTexto, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.nunito(
            color: AppColors.textoSuave, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosa,
          foregroundColor: AppColors.texto,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.baloo2(
              fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rosaOscuro,
          side: const BorderSide(color: AppColors.rosa, width: 2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.baloo2(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
