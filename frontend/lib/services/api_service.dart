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
        return '${base.scheme}://$host/api';
      } catch (_) {
        return 'http://localhost:8000/api';
      }
    }
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

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String nombre,
    required int edad,
    required String avatar,
    required String email,
    required String password,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: _headers(),
      body: json.encode({
        'nombre': nombre, 'edad': edad, 'avatar': avatar,
        'email': email, 'password': password,
      }),
    );
    final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    if (r.statusCode == 200 || r.statusCode == 201) return body;
    throw Exception(body['error'] ?? 'Error al registrar');
  }

  Future<Map<String, dynamic>> loginEmail(String email, String password) async {
    final r = await http.post(
      Uri.parse('$baseUrl/login-email/'),
      headers: _headers(),
      body: json.encode({'email': email, 'password': password}),
    );
    final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    if (r.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Correo o contraseña incorrectos');
  }

  Future<Map<String, dynamic>> login(String nombre, int edad, String avatar) async {
    final r = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: _headers(),
      body: json.encode({'nombre': nombre, 'edad': edad, 'avatar': avatar}),
    );
    if (r.statusCode == 200 || r.statusCode == 201) {
      return json.decode(utf8.decode(r.bodyBytes));
    }
    throw Exception('Error al iniciar sesión');
  }

  Future<Map<String, dynamic>> verifyToken(String token) async {
    final r = await http.post(
      Uri.parse('$baseUrl/verify-token/'),
      headers: _headers(),
      body: json.encode({'token': token}),
    );
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    throw Exception('Token inválido o expirado');
  }

  // ── Estudiantes ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getEstudiante(int id, {String? token}) async {
    final r = await http.get(
      Uri.parse('$baseUrl/estudiante/$id/'),
      headers: _headers(token: token),
    );
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    throw Exception('Error al cargar estudiante');
  }

  Future<Map<String, dynamic>> actualizarPerfil(
      int id, String nombre, String avatar, {String? token}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/estudiante/$id/actualizar/'),
      headers: _headers(token: token),
      body: json.encode({'nombre': nombre, 'avatar': avatar}),
    );
    final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    if (r.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Error al actualizar perfil');
  }

  Future<void> cambiarPassword(
      int id, String actual, String nuevo, {String? token}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/estudiante/$id/password/'),
      headers: _headers(token: token),
      body: json.encode({'password_actual': actual, 'password_nuevo': nuevo}),
    );
    final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    if (r.statusCode != 200) throw Exception(body['error'] ?? 'Error al cambiar contraseña');
  }

  Future<List<dynamic>> getRanking({int? edad, String? token}) async {
    var url = '$baseUrl/ranking/';
    if (edad != null) url += '?edad=$edad';
    final r = await http.get(Uri.parse(url), headers: _headers(token: token));
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    return [];
  }

  // ── Logros y Tienda ───────────────────────────────────────────────────────

  Future<List<dynamic>> getLogros({String? token}) async {
    final r = await http.get(Uri.parse('$baseUrl/logros/'), headers: _headers(token: token));
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    return [];
  }

  Future<List<dynamic>> getObjetosTienda({String? token}) async {
    final r = await http.get(Uri.parse('$baseUrl/tienda/'), headers: _headers(token: token));
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    return [];
  }

  Future<Map<String, dynamic>> comprarObjeto(int estudianteId, int objetoId, {String? token}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/comprar/'),
      headers: _headers(token: token),
      body: json.encode({'estudiante_id': estudianteId, 'objeto_id': objetoId}),
    );
    final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    if (r.statusCode == 200) return body;
    throw Exception(body['error'] ?? 'Error al comprar');
  }

  Future<void> equiparObjeto(int estudianteId, int compraId, {String? token}) async {
    await http.post(
      Uri.parse('$baseUrl/equipar/'),
      headers: _headers(token: token),
      body: json.encode({'estudiante_id': estudianteId, 'compra_id': compraId}),
    );
  }

  // ── Libros ────────────────────────────────────────────────────────────────

  Future<List<dynamic>> getLibros({String? token, int? edad}) async {
    var url = '$baseUrl/libros/';
    if (edad != null) url += '?edad=$edad';
    final r = await http.get(Uri.parse(url), headers: _headers(token: token));
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    return [];
  }

  Future<Map<String, dynamic>> getLibroDetalle(String slug, {String? token}) async {
    final r = await http.get(
      Uri.parse('$baseUrl/libros/$slug/'),
      headers: _headers(token: token),
    );
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    throw Exception('Error al cargar libro');
  }

  // ── Actividades ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> guardarResultado({
    required int estudianteId,
    required int libroId,
    required int puntos,
    required int total,
    String? token,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/guardar/'),
      headers: _headers(token: token),
      body: json.encode({
        'estudiante_id': estudianteId, 'libro_id': libroId,
        'puntos': puntos, 'total': total,
      }),
    );
    if (r.statusCode == 200 || r.statusCode == 201) {
      return json.decode(utf8.decode(r.bodyBytes));
    }
    throw Exception('Error al guardar resultado');
  }

  Future<List<dynamic>> getProgreso(int estudianteId, {String? token}) async {
    final r = await http.get(
      Uri.parse('$baseUrl/progreso/$estudianteId/'),
      headers: _headers(token: token),
    );
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    return [];
  }

  Future<BookGameData> getJuegos(String slug, {String? token}) async {
    final r = await http.get(
      Uri.parse('$baseUrl/juegos/$slug/'),
      headers: _headers(token: token),
    );
    if (r.statusCode == 200) {
      return BookGameData.fromJson(json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
    }
    throw Exception('Error al cargar juegos');
  }

  Future<List<dynamic>> getHistorial(int estudianteId, {String? token}) async {
    final r = await http.get(
      Uri.parse('$baseUrl/historial/$estudianteId/'),
      headers: _headers(token: token),
    );
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    return [];
  }

  Future<void> completarActividad(String slug, String tipo, {String? token}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/completar-actividad/'),
      headers: _headers(token: token),
      body: json.encode({'slug': slug, 'tipo': tipo}),
    );
    if (r.statusCode != 200) {
      throw Exception('Error al completar actividad');
    }
  }
}
