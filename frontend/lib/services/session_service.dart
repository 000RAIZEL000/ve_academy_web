import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _token = 'auth_token';
  static const _id = 'est_id';
  static const _edad = 'est_edad';
  static const _nombre = 'est_nombre';
  static const _avatar = 'est_avatar';
  static const _puntos = 'est_puntos';
  static const _racha = 'est_racha';

  static Future<void> saveSession(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_token, data['token'] as String? ?? '');
    await p.setInt(_id, (data['id'] as num?)?.toInt() ?? 0);
    await p.setInt(_edad, (data['edad'] as num?)?.toInt() ?? 5);
    await p.setString(_nombre, data['nombre'] as String? ?? '');
    await p.setString(_avatar, data['avatar'] as String? ?? 'panda');
    await p.setInt(_puntos, (data['puntos'] as num?)?.toInt() ?? 0);
    await p.setInt(_racha, (data['racha_actual'] as num?)?.toInt() ?? 0);
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final p = await SharedPreferences.getInstance();
    final token = p.getString(_token);
    final id = p.getInt(_id);
    if (token == null || token.isEmpty || id == null || id == 0) return null;
    return {
      'token': token,
      'id': id,
      'edad': p.getInt(_edad) ?? 5,
      'nombre': p.getString(_nombre) ?? '',
      'avatar': p.getString(_avatar) ?? 'panda',
      'puntos': p.getInt(_puntos) ?? 0,
      'racha_actual': p.getInt(_racha) ?? 0,
    };
  }

  /// Suma [cantidad] a los puntos actuales. Nunca reemplaza el total.
  static Future<int> agregarPuntos(int cantidad) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt(_puntos) ?? 0;
    final newTotal = current + cantidad;
    await p.setInt(_puntos, newTotal);
    return newTotal;
  }

  /// Alias de [agregarPuntos] — SUMA, no reemplaza.
  static Future<void> updatePuntos(int cantidad) async {
    await agregarPuntos(cantidad);
  }

  /// Establece el total exacto. Solo usar cuando el servidor es autoritativo
  /// (login, token verify, compra en tienda).
  static Future<void> setPuntos(int total) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_puntos, total);
  }

  static Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_token);
    await p.remove(_id);
    await p.remove(_edad);
    await p.remove(_nombre);
    await p.remove(_avatar);
    await p.remove(_puntos);
    await p.remove(_racha);
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_token);
  }
}
