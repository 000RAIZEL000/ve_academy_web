import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/game_data.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      try {
        final base = Uri.base;
        final host = base.host;
        if (host == 'localhost' || host == '127.0.0.1') {
          return 'http://localhost:8000/api';
        }
        // En producción (Railway): mismo host que la web
        return '${base.scheme}://$host/api';
      } catch (_) {
        return 'http://localhost:8000/api';
      }
    }
    // Android emulator
    return 'http://10.0.2.2:8000/api';
  }

  static String resolveStaticUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (kIsWeb) {
      try {
        final base = Uri.base;
        final host = base.host;
        if (host == 'localhost' || host == '127.0.0.1') {
          return 'http://localhost:8000$path';
        }
        return '${base.scheme}://$host$path';
      } catch (_) {
        return 'http://localhost:8000$path';
      }
    }
    return 'http://10.0.2.2:8000$path';
  }

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  // ── Auth ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String nombre, int edad, String avatar) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: _headers(),
      body: json.encode({'nombre': nombre, 'edad': edad, 'avatar': avatar}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error al iniciar sesión');
  }

  Future<Map<String, dynamic>> verifyToken(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-token/'),
      headers: _headers(),
      body: json.encode({'token': token}),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Token inválido o expirado');
  }

  // ── Estudiantes ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getEstudiante(int id, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/estudiante/$id/'),
      headers: _headers(token: token),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error al cargar estudiante');
  }

  Future<List<dynamic>> getRanking({int? edad, String? token}) async {
    var url = '$baseUrl/ranking/';
    if (edad != null) url += '?edad=$edad';
    final response = await http.get(Uri.parse(url), headers: _headers(token: token));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return [];
  }

  // ── Logros y Tienda ─────────────────────────────────────────────────

  Future<List<dynamic>> getLogros({String? token}) async {
    final response = await http.get(Uri.parse('$baseUrl/logros/'), headers: _headers(token: token));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return [];
  }

  Future<List<dynamic>> getObjetosTienda({String? token}) async {
    final response = await http.get(Uri.parse('$baseUrl/tienda/'), headers: _headers(token: token));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return [];
  }

  Future<Map<String, dynamic>> comprarObjeto(int estudianteId, int objetoId, {String? token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comprar/'),
      headers: _headers(token: token),
      body: json.encode({'estudiante_id': estudianteId, 'objeto_id': objetoId}),
    );
    return json.decode(utf8.decode(response.bodyBytes));
  }

  // ── Libros ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getLibros({String? token}) async {
    final response = await http.get(Uri.parse('$baseUrl/libros/'), headers: _headers(token: token));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return [];
  }

  Future<Map<String, dynamic>> getLibroDetalle(String slug, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/libros/$slug/'),
      headers: _headers(token: token),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error al cargar libro');
  }

  // ── Actividades ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> guardarResultado({
    required int estudianteId,
    required int libroId,
    required int puntos,
    required int total,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/guardar/'),
      headers: _headers(token: token),
      body: json.encode({
        'estudiante_id': estudianteId,
        'libro_id': libroId,
        'puntos': puntos,
        'total': total,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Error al guardar resultado');
  }

  Future<List<dynamic>> getProgreso(int estudianteId, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/progreso/$estudianteId/'),
      headers: _headers(token: token),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return [];
  }

  Future<BookGameData> getJuegos(String slug, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/juegos/$slug/'),
      headers: _headers(token: token),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return BookGameData.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Error al cargar juegos');
  }

  Future<List<dynamic>> getHistorial(int estudianteId, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/historial/$estudianteId/'),
      headers: _headers(token: token),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return [];
  }
}
