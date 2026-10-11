import 'package:dio/dio.dart';

import '../../domain/entities/admin_communique.dart';

class AdminCommuniqueRemoteDataSource {
  const AdminCommuniqueRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<AdminSession> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/admin/auth/login',
      data: {'username': username, 'password': password},
    );
    return AdminSession.fromJson(response.data ?? const {});
  }

  Future<List<AdminCommunique>> fetchAll(String token) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/admin/communiques',
      options: _authorized(token),
    );
    return (response.data ?? const [])
        .whereType<Map>()
        .map((row) => AdminCommunique.fromJson(Map<String, dynamic>.from(row)))
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<AdminCommunique> createDraft(
    String token, {
    required String title,
    required String body,
    required int type,
    String? imageUrl,
    DateTime? expiresAt,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/admin/communiques',
      data: _requestBody(
        title: title,
        body: body,
        type: type,
        imageUrl: imageUrl,
        expiresAt: expiresAt,
      ),
      options: _authorized(token),
    );
    return AdminCommunique.fromJson(response.data ?? const {});
  }

  Future<AdminCommunique> updateDraft(
    String token,
    String id, {
    required String title,
    required String body,
    required int type,
    String? imageUrl,
    DateTime? expiresAt,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/admin/communiques/$id',
      data: _requestBody(
        title: title,
        body: body,
        type: type,
        imageUrl: imageUrl,
        expiresAt: expiresAt,
      ),
      options: _authorized(token),
    );
    return AdminCommunique.fromJson(response.data ?? const {});
  }

  Future<void> publish(String token, String id) async {
    await _dio.post<void>(
      '/api/v1/admin/communiques/$id/publish',
      options: _authorized(token),
    );
  }

  Future<void> archive(String token, String id) async {
    await _dio.post<void>(
      '/api/v1/admin/communiques/$id/archive',
      options: _authorized(token),
    );
  }

  Future<void> changePassword(
    String token, {
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '/api/v1/admin/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      options: _authorized(token),
    );
  }

  Future<void> createAdminUser(
    String token, {
    required String fullName,
    required String username,
    required String password,
  }) async {
    await _dio.post<void>(
      '/api/v1/admin/users',
      data: {
        'fullName': fullName.trim(),
        'username': username.trim(),
        'password': password,
      },
      options: _authorized(token),
    );
  }

  Options _authorized(String token) => Options(
        headers: {'Authorization': 'Bearer $token'},
      );

  Map<String, dynamic> _requestBody({
    required String title,
    required String body,
    required int type,
    String? imageUrl,
    DateTime? expiresAt,
  }) => {
        'title': title.trim(),
        'body': body.trim(),
        'type': type,
        'imageUrl': imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
        'expiresAt': expiresAt?.toUtc().toIso8601String(),
      };
}