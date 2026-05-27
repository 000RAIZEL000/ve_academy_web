import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const _usersKey = 'offline_users';

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static bool verifyPassword(String plain, String hash) {
    return hashPassword(plain) == hash;
  }

  static Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, json.encode(users));
  }

  static Future<Map<String, dynamic>?> findUser(String email) async {
    final users = await _loadUsers();
    final lower = email.toLowerCase();
    for (final u in users) {
      if ((u['email'] as String?)?.toLowerCase() == lower) return u;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> findUserById(int id) async {
    final users = await _loadUsers();
    for (final u in users) {
      if (u['id'] == id) return u;
    }
    return null;
  }

  static Future<Map<String, dynamic>> saveUser({
    required String nombre,
    required int edad,
    required String avatar,
    required String email,
    required String password,
  }) async {
    final users = await _loadUsers();
    final lower = email.toLowerCase();
    if (users.any((u) => (u['email'] as String?)?.toLowerCase() == lower)) {
      throw Exception('Ya existe una cuenta con ese correo');
    }
    // Negative ID to avoid collision with server IDs
    final localId = -(DateTime.now().millisecondsSinceEpoch % 1000000000);
    final user = <String, dynamic>{
      'id': localId,
      'nombre': nombre,
      'edad': edad,
      'avatar': avatar,
      'email': lower,
      'password_hash': hashPassword(password),
      'puntos': 0,
      'racha_actual': 0,
    };
    users.add(user);
    await _saveUsers(users);
    return user;
  }

  static Future<void> updatePoints(int userId, int puntosAAgregar) async {
    final users = await _loadUsers();
    final idx = users.indexWhere((u) => u['id'] == userId);
    if (idx != -1) {
      final current = (users[idx]['puntos'] as num?)?.toInt() ?? 0;
      users[idx]['puntos'] = current + puntosAAgregar;
      await _saveUsers(users);
    }
  }

  static Map<String, dynamic> buildSession(Map<String, dynamic> user) {
    return {
      'token': 'offline_${user['id']}',
      'id': user['id'],
      'nombre': user['nombre'],
      'edad': user['edad'],
      'avatar': user['avatar'],
      'avatar_url': 'assets/avatars/${user['avatar']}.png',
      'puntos': user['puntos'] ?? 0,
      'racha_actual': user['racha_actual'] ?? 0,
    };
  }

  // ── Pending progress queue (for server users who go offline) ──────────────

  static const _pendingKey = 'pending_progress';

  static Future<void> queueProgress({
    required int estudianteId,
    required int libroId,
    required int puntos,
    required int total,
  }) async {
    if (estudianteId <= 0) return; // local-only users don't sync
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey) ?? '[]';
    final list = (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    list.add({'estudiante_id': estudianteId, 'libro_id': libroId, 'puntos': puntos, 'total': total});
    await prefs.setString(_pendingKey, json.encode(list));
  }

  static Future<List<Map<String, dynamic>>> getPendingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return [];
    return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  static Future<void> clearPendingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
  }

  // ── Token helpers ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllUsers() => _loadUsers();

  static bool isOfflineToken(String token) => token.startsWith('offline_');

  static int? userIdFromToken(String token) {
    if (!isOfflineToken(token)) return null;
    return int.tryParse(token.replaceFirst('offline_', ''));
  }
}
