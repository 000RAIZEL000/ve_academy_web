import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/game_data.dart';
import '../data/datos_locales.dart';
import 'local_auth_service.dart';

class ApiService {
  // Se pone en true la primera vez que falla la conexión al backend.
  static bool _modoOffline = false;
  static bool get modoOffline => _modoOffline;

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
    if (path.startsWith('assets/')) return path;
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
    if (!_modoOffline) {
      try {
        final r = await http.post(
          Uri.parse('$baseUrl/register/'),
          headers: _headers(),
          body: json.encode({
            'nombre': nombre, 'edad': edad, 'avatar': avatar,
            'email': email, 'password': password,
          }),
        ).timeout(const Duration(seconds: 5));
        final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
        if (r.statusCode == 200 || r.statusCode == 201) return body;
        // Server-side validation error (e.g. duplicate email) — re-throw, don't go offline
        throw Exception(body['error'] ?? 'Error al registrar');
      } on Exception catch (e) {
        if (e.toString().contains('Error al registrar') ||
            e.toString().contains('correo') ||
            e.toString().contains('email')) { rethrow; }
        _modoOffline = true;
      }
    }
    // Offline path
    final user = await LocalAuthService.saveUser(
      nombre: nombre, edad: edad, avatar: avatar,
      email: email, password: password,
    );
    return LocalAuthService.buildSession(user);
  }

  Future<Map<String, dynamic>> loginEmail(String email, String password) async {
    if (!_modoOffline) {
      try {
        final r = await http.post(
          Uri.parse('$baseUrl/login-email/'),
          headers: _headers(),
          body: json.encode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 5));
        final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
        if (r.statusCode == 200) return body;
        // Wrong credentials — re-throw, don't fall through to offline
        throw Exception(body['error'] ?? 'Correo o contraseña incorrectos');
      } on Exception catch (e) {
        if (e.toString().contains('Correo') || e.toString().contains('contraseña') ||
            e.toString().contains('password') || e.toString().contains('incorrectos')) { rethrow; }
        _modoOffline = true;
      }
    }
    // Offline path
    final user = await LocalAuthService.findUser(email);
    if (user == null) {
      throw Exception('No se encontró una cuenta con ese correo (sin conexión)');
    }
    if (!LocalAuthService.verifyPassword(password, user['password_hash'] as String)) {
      throw Exception('Contraseña incorrecta');
    }
    return LocalAuthService.buildSession(user);
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
    if (LocalAuthService.isOfflineToken(token)) {
      final userId = LocalAuthService.userIdFromToken(token);
      if (userId == null) throw Exception('Token offline inválido');
      final user = await LocalAuthService.findUserById(userId);
      if (user == null) throw Exception('Usuario offline no encontrado');
      _modoOffline = true;
      return LocalAuthService.buildSession(user);
    }
    final r = await http.post(
      Uri.parse('$baseUrl/verify-token/'),
      headers: _headers(),
      body: json.encode({'token': token}),
    ).timeout(const Duration(seconds: 5));
    if (r.statusCode == 200) {
      final data = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      // Sync any queued progress from offline sessions
      _syncPending(token: token).ignore();
      return data;
    }
    throw Exception('Token inválido o expirado');
  }

  Future<void> _syncPending({String? token}) async {
    final pending = await LocalAuthService.getPendingProgress();
    if (pending.isEmpty) return;
    try {
      for (final entry in pending) {
        await http.post(
          Uri.parse('$baseUrl/guardar/'),
          headers: _headers(token: token),
          body: json.encode(entry),
        ).timeout(const Duration(seconds: 5));
      }
      await LocalAuthService.clearPendingProgress();
    } catch (_) {
      // Keep pending entries for next sync attempt
    }
  }

  // ── Estudiantes ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getEstudiante(int id, {String? token}) async {
    final r = await http.get(
      Uri.parse('$baseUrl/estudiante/$id/'),
      headers: _headers(token: token),
    ).timeout(const Duration(seconds: 5));
    if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
    throw Exception('Error al cargar estudiante');
  }

  Future<Map<String, dynamic>> actualizarPerfil(
      int id, String nombre, String avatar, {String? token}) async {
    if (_modoOffline) {
      return {'nombre': nombre, 'avatar': avatar,
              'avatar_url': 'assets/avatars/$avatar.png', 'offline': true};
    }
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/estudiante/$id/actualizar/'),
        headers: _headers(token: token),
        body: json.encode({'nombre': nombre, 'avatar': avatar}),
      ).timeout(const Duration(seconds: 5));
      final body = json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      if (r.statusCode == 200) return body;
      throw Exception(body['error'] ?? 'Error al actualizar perfil');
    } catch (e) {
      if (e is Exception && e.toString().contains('Error al actualizar')) rethrow;
      _modoOffline = true;
      return {'nombre': nombre, 'avatar': avatar,
              'avatar_url': 'assets/avatars/$avatar.png', 'offline': true};
    }
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
    if (_modoOffline) return [];
    try {
      var url = '$baseUrl/ranking/';
      if (edad != null) url += '?edad=$edad';
      final r = await http.get(Uri.parse(url), headers: _headers(token: token))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── Logros y Tienda ───────────────────────────────────────────────────────

  Future<List<dynamic>> getLogros({String? token}) async {
    if (_modoOffline) return [];
    try {
      final r = await http.get(Uri.parse('$baseUrl/logros/'), headers: _headers(token: token))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getObjetosTienda({String? token}) async {
    if (_modoOffline) return DatosLocales.getTienda();
    try {
      final r = await http.get(Uri.parse('$baseUrl/tienda/'), headers: _headers(token: token))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
      return DatosLocales.getTienda();
    } catch (_) {
      _modoOffline = true;
      return DatosLocales.getTienda();
    }
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
    if (_modoOffline) return DatosLocales.getLibros(edad: edad);
    try {
      var url = '$baseUrl/libros/';
      if (edad != null) url += '?edad=$edad';
      final r = await http.get(Uri.parse(url), headers: _headers(token: token))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
      return DatosLocales.getLibros(edad: edad);
    } catch (_) {
      _modoOffline = true;
      return DatosLocales.getLibros(edad: edad);
    }
  }

  Future<Map<String, dynamic>> getLibroDetalle(String slug, {String? token}) async {
    if (!_modoOffline) {
      try {
        final r = await http.get(
          Uri.parse('$baseUrl/libros/$slug/'),
          headers: _headers(token: token),
        ).timeout(const Duration(seconds: 5));
        if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
      } catch (_) {
        _modoOffline = true;
      }
    }
    final local = DatosLocales.getLibroDetalle(slug);
    if (local != null) return local;
    throw Exception('Libro no encontrado');
  }

  // ── Actividades ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> guardarResultado({
    required int estudianteId,
    required int libroId,
    required int puntos,
    required int total,
    String? token,
  }) async {
    if (_modoOffline) {
      final puntosReales = puntos * 10;
      await LocalAuthService.updatePoints(estudianteId, puntosReales);
      final user = await LocalAuthService.findUserById(estudianteId);
      final totalPuntos = (user?['puntos'] as num?)?.toInt() ?? puntosReales;
      return {'puntos_ganados': puntosReales, 'puntos_totales': totalPuntos, 'offline': true};
    }
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/guardar/'),
        headers: _headers(token: token),
        body: json.encode({
          'estudiante_id': estudianteId, 'libro_id': libroId,
          'puntos': puntos, 'total': total,
        }),
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200 || r.statusCode == 201) {
        return json.decode(utf8.decode(r.bodyBytes));
      }
      throw Exception('Error al guardar resultado');
    } catch (e) {
      if (e is Exception && e.toString().contains('Error al guardar')) rethrow;
      _modoOffline = true;
      final puntosReales = puntos * 10;
      await LocalAuthService.updatePoints(estudianteId, puntosReales);
      await LocalAuthService.queueProgress(
        estudianteId: estudianteId, libroId: libroId, puntos: puntos, total: total);
      final user = await LocalAuthService.findUserById(estudianteId);
      final totalPuntos = (user?['puntos'] as num?)?.toInt() ?? puntosReales;
      return {'puntos_ganados': puntosReales, 'puntos_totales': totalPuntos, 'offline': true};
    }
  }

  Future<List<dynamic>> getProgreso(int estudianteId, {String? token}) async {
    if (_modoOffline) return [];
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/progreso/$estudianteId/'),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<BookGameData> getJuegos(String slug, {String? token}) async {
    if (!_modoOffline) {
      try {
        final r = await http.get(
          Uri.parse('$baseUrl/juegos/$slug/'),
          headers: _headers(token: token),
        ).timeout(const Duration(seconds: 5));
        if (r.statusCode == 200) {
          return BookGameData.fromJson(json.decode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
        }
      } catch (_) {
        _modoOffline = true;
      }
    }
    final local = DatosLocales.getJuegos(slug);
    if (local != null) return local;
    throw Exception('Juegos no encontrados');
  }

  Future<List<dynamic>> getHistorial(int estudianteId, {String? token}) async {
    if (_modoOffline) return [];
    try {
      final r = await http.get(
        Uri.parse('$baseUrl/historial/$estudianteId/'),
        headers: _headers(token: token),
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return json.decode(utf8.decode(r.bodyBytes));
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> completarActividad(String slug, String tipo, {String? token, int? estudianteId}) async {
    if (_modoOffline) {
      if (estudianteId != null) await LocalAuthService.updatePoints(estudianteId, 5);
      return;
    }
    try {
      final r = await http.post(
        Uri.parse('$baseUrl/completar-actividad/'),
        headers: _headers(token: token),
        body: json.encode({'slug': slug, 'tipo': tipo}),
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode != 200) throw Exception('Error al completar actividad');
    } catch (e) {
      if (e is Exception && e.toString().contains('Error al completar')) rethrow;
      _modoOffline = true;
      if (estudianteId != null) await LocalAuthService.updatePoints(estudianteId, 5);
    }
  }
}
