import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Central service for tracking student progress locally.
/// Manages: books read, games completed, and activity history.
/// Points are managed separately via SessionService + server.
class ProgressService {
  static const _keyLibros = 'prog_libros_leidos';
  static const _keyJuegos = 'prog_juegos_completados';
  static const _keyHistorial = 'prog_historial';

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns list of completed books: [{slug, titulo}]
  static Future<List<Map<String, dynamic>>> getLibrosLeidos() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyLibros);
    if (raw == null) return [];
    try {
      return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<int> getLibrosLeidosCount() async =>
      (await getLibrosLeidos()).length;

  static Future<int> getJuegosCompletados() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyJuegos) ?? 0;
  }

  /// Returns activity history in server-compatible format (newest first).
  static Future<List<Map<String, dynamic>>> getHistorial() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyHistorial);
    if (raw == null) return [];
    try {
      return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getStats() async {
    final libros = await getLibrosLeidos();
    return {
      'libros_leidos': libros.length,
      'libros_lista': libros,
      'juegos_completados': await getJuegosCompletados(),
    };
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Records a completed book (deduplicated by slug).
  static Future<void> completarLibro({
    required String slug,
    required String titulo,
    required int puntosGanados,
  }) async {
    final p = await SharedPreferences.getInstance();
    final libros = await getLibrosLeidos();
    if (!libros.any((l) => l['slug'] == slug)) {
      libros.add({'slug': slug, 'titulo': titulo});
      await p.setString(_keyLibros, json.encode(libros));
    }
    await _addHistorial({
      'libro_titulo': titulo,
      'libro_slug': slug,
      'tipo': 'libro',
      'puntos_obtenidos': puntosGanados,
      'completado': true,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  /// Increments minigame counter and records in history.
  static Future<void> completarJuego({
    required String slug,
    required String tipo,
  }) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt(_keyJuegos) ?? 0;
    await p.setInt(_keyJuegos, current + 1);
    await _addHistorial({
      'libro_titulo': 'Minijuego ($tipo)',
      'libro_slug': slug,
      'tipo': 'juego',
      'puntos_obtenidos': 5,
      'completado': true,
      'fecha': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> _addHistorial(Map<String, dynamic> entry) async {
    final p = await SharedPreferences.getInstance();
    final historial = await getHistorial();
    historial.insert(0, entry);
    if (historial.length > 50) historial.removeRange(50, historial.length);
    await p.setString(_keyHistorial, json.encode(historial));
  }

  // ── Sync from server ──────────────────────────────────────────────────────

  /// Syncs juegos_completados from server (takes the higher value).
  static Future<void> syncFromServer(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();
    if (data['juegos_completados'] != null) {
      final serverVal = (data['juegos_completados'] as num).toInt();
      final localVal = p.getInt(_keyJuegos) ?? 0;
      if (serverVal > localVal) await p.setInt(_keyJuegos, serverVal);
    }
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyLibros);
    await p.remove(_keyJuegos);
    await p.remove(_keyHistorial);
  }
}
