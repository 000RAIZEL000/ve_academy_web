import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'auth_token';
  static const String _idKey = 'estudiante_id';
  static const String _edadKey = 'estudiante_edad';

  static Future<void> saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, data['token'] as String);
    await prefs.setInt(_idKey, data['id'] as int);
    await prefs.setInt(_edadKey, data['edad'] as int);
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final id = prefs.getInt(_idKey);
    final edad = prefs.getInt(_edadKey);
    if (token == null || id == null || edad == null) return null;
    return {'token': token, 'id': id, 'edad': edad};
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_idKey);
    await prefs.remove(_edadKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
