import 'package:flutter/material.dart';

class AppColors {
  // Paleta pastel principal obligatoria
  static const Color rosa = Color(0xFFF8BBD9);
  static const Color lila = Color(0xFFDCC6FF);
  static const Color celeste = Color(0xFFBDE7FF);
  static const Color amarillo = Color(0xFFFFF2A6);
  static const Color blanco = Color(0xFFFFFDF8);

  // Variantes oscuras para texto y estados activos
  static const Color rosaOscuro = Color(0xFFD4639A);
  static const Color lilaOscuro = Color(0xFF8B5CF6);
  static const Color celesteOscuro = Color(0xFF0EA5E9);
  static const Color amarilloOscuro = Color(0xFFF59E0B);
  static const Color verdeClaro = Color(0xFFBBF7D0);
  static const Color verdeOscuro = Color(0xFF16A34A);
  static const Color naranjaClaro = Color(0xFFFFD6B0);
  static const Color naranjaOscuro = Color(0xFFEA580C);

  // Texto
  static const Color texto = Color(0xFF4A4565);
  static const Color textoSuave = Color(0xFF8B85A8);
  static const Color textoBlanco = Colors.white;

  // Fondos
  static const Color fondo = Color(0xFFFFFDF8);
  static const Color fondoTarjeta = Colors.white;
  static const Color fondoSecundario = Color(0xFFF5F0FF);

  // Estado
  static const Color exito = Color(0xFF86EFAC);
  static const Color error = Color(0xFFFCA5A5);
  static const Color exitoTexto = Color(0xFF15803D);
  static const Color errorTexto = Color(0xFFDC2626);

  // Degradados
  static const LinearGradient gradientePrimario = LinearGradient(
    colors: [rosa, lila],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteSplash = LinearGradient(
    colors: [Color(0xFFFDE8F5), Color(0xFFEDE4FF), Color(0xFFDBF0FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradienteNavbar = LinearGradient(
    colors: [rosa, lila],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteLogros = LinearGradient(
    colors: [amarillo, Color(0xFFFFE066)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteHome = LinearGradient(
    colors: [Color(0xFFFDE8F5), Color(0xFFEDE4FF), Color(0xFFDBF0FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Colores para tarjetas (ciclo)
  static const List<Color> tarjetas = [
    Color(0xFFFDE8F5), Color(0xFFEDE4FF), Color(0xFFDBF0FF),
    Color(0xFFFFFBD4), Color(0xFFD4F1E4), Color(0xFFFFE8D6),
  ];

  // Colores para avatares
  static const List<Color> coloresAvatares = [
    Color(0xFFFDE8F5), Color(0xFFEDE4FF), Color(0xFFDBF0FF),
    Color(0xFFFFFBD4), Color(0xFFD4F1E4), Color(0xFFFFE8D6),
    Color(0xFFF0E6FF), Color(0xFFE8F4FF), Color(0xFFFFF0E6),
  ];

  static BoxShadow get sombraSuave => BoxShadow(
    color: const Color(0xFFDCC6FF).withOpacity(0.25),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static BoxShadow get sombraRosa => BoxShadow(
    color: rosa.withOpacity(0.35),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );

  static BoxShadow get sombraLila => BoxShadow(
    color: lila.withOpacity(0.35),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );

  // Compatibilidad con pantallas legadas
  static const Color verde = Color(0xFF81C784);
  static const Color azul = Color(0xFF64B5F6);
  static const Color azulOscuro = Color(0xFF1976D2);
  static const Color naranja = Color(0xFFFFB74D);
  static const Color morado = Color(0xFFCE93D8);
  static const Color rojo = Color(0xFFEF9A9A);
  static const Color gris = Color(0xFF9E9E9E);
  static const Color headerGradientStart = rosa;
  static const Color headerGradientMid = lila;
  static const Color headerGradientEnd = celeste;
  static const List<List<Color>> featureGradients = [
    [rosa, lila], [lila, celeste], [celeste, amarillo],
    [amarillo, rosa], [rosa, celeste], [lila, amarillo],
    [celeste, rosa], [amarillo, lila], [rosa, lila],
    [lila, celeste], [celeste, amarillo], [amarillo, rosa],
    [rosa, celeste], [lila, amarillo], [celeste, rosa],
  ];
}
