import 'package:shared_preferences/shared_preferences.dart';

abstract class AppUpdateDismissService {
  static const _key = 'app_update_dismissed_version';

  static Future<String?> loadDismissedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static Future<void> dismissVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, version.trim());
  }
}
