import 'package:flutter/material.dart';

class AppColors {
  // Paleta base
  static const Color verde = Color(0xFF2ecc71);
  static const Color verdeOscuro = Color(0xFF27ae60);
  static const Color naranja = Color(0xFFf39c12);
  static const Color naranjaOscuro = Color(0xFFe67e22);
  static const Color azul = Color(0xFF3498db);
  static const Color azulOscuro = Color(0xFF2980b9);
  static const Color rosa = Color(0xFFe91e8c);
  static const Color amarillo = Color(0xFFf1c40f);
  static const Color morado = Color(0xFF9b59b6);
  static const Color rojo = Color(0xFFe74c3c);
  static const Color fondo = Color(0xFFfef9f0);
  static const Color texto = Color(0xFF2c3e50);
  static const Color gris = Color(0xFF7f8c8d);

  // Header gradient
  static const Color headerGradientStart = Color(0xFF1a1a2e);
  static const Color headerGradientMid = Color(0xFF16213e);
  static const Color headerGradientEnd = Color(0xFF0f3460);

  // Gradients para las 15 funcionalidades
  static const List<List<Color>> featureGradients = [
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Biblioteca - púrpura
    [Color(0xFFf7971e), Color(0xFFffd200)], // Quiz - naranja/dorado
    [Color(0xFF11998e), Color(0xFF38ef7d)], // Mi Progreso - verde esmeralda
    [Color(0xFFf6d365), Color(0xFFfda085)], // Logros - dorado/durazno
    [Color(0xFF2980B9), Color(0xFF6DD5FA)], // Ranking - azul celeste
    [Color(0xFFE91E8C), Color(0xFFfc466b)], // Tienda - rosa fucsia
    [Color(0xFFff416c), Color(0xFFff4b2b)], // Rachas - rojo fuego
    [Color(0xFF43C6AC), Color(0xFF1a6b5a)], // Mi Perfil - esmeralda oscuro
    [Color(0xFF0ba360), Color(0xFF3cba92)], // Panel Docente - verde bosque
    [Color(0xFFfc4a1a), Color(0xFFf7b733)], // Reportes - naranja fuego
    [Color(0xFF4776e6), Color(0xFF8e54e9)], // Niveles - indigo/lila
    [Color(0xFF06beb6), Color(0xFF48b1bf)], // Modo Escucha - aguamarina
    [Color(0xFFe879f9), Color(0xFFa855f7)], // Historial - violeta
    [Color(0xFF29323c), Color(0xFF485563)], // Gestión - pizarrón
    [Color(0xFF2c3e50), Color(0xFF4ca1af)], // Admin - azul acero
  ];
}
