import 'package:shared_preferences/shared_preferences.dart';

/// Cache local du token FCM pour les appels API sécurisés.
class FcmTokenCache {
  static const _key = 'fcm_token';

  static String? _memory;

  static String? get current => _memory;

  static Future<void> save(String? token) async {
    _memory = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, token);
    }
  }

  static Future<String?> load() async {
    if (_memory != null && _memory!.isNotEmpty) return _memory;
    final prefs = await SharedPreferences.getInstance();
    _memory = prefs.getString(_key);
    return _memory;
  }
}
