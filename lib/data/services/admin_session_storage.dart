import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/admin_communique.dart';

class AdminSessionStorage {
  AdminSessionStorage._();

  static const _key = 'admin_session';
  static const _storage = FlutterSecureStorage();

  static Future<void> save(AdminSession session) => _storage.write(
        key: _key,
        value: jsonEncode({
          'accessToken': session.accessToken,
          'expiresAt': session.expiresAt.toIso8601String(),
          'fullName': session.fullName,
          'role': session.role,
        }),
      );

  static Future<AdminSession?> read() async {
    final encoded = await _storage.read(key: _key);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) throw const FormatException('Invalid admin session');
      final session = AdminSession.fromJson(Map<String, dynamic>.from(decoded));
      if (session.accessToken.isEmpty || session.isExpired) {
        await clear();
        return null;
      }
      return session;
    } on FormatException {
      await clear();
      return null;
    }
  }

  static Future<void> clear() => _storage.delete(key: _key);
}