import 'package:dio/dio.dart';
import '../../core/network/notifications_api_config.dart';
import '../../core/network/notifications_auth_interceptor.dart';
import '../../domain/entities/notification_item.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationItem>> fetchNotifications({
    required String installationId,
    int limit = 50,
  });

  Future<int> fetchUnreadCount(String installationId);

  Future<void> markRead({
    required String installationId,
    required String notificationId,
  });

  Future<void> markAllRead(String installationId);

  Future<void> registerDevice({
    required String installationId,
    required String fcmToken,
    required int platform,
    required String locale,
    String? appVersion,
  });

  Future<void> updateToken({
    required String installationId,
    required String fcmToken,
    String? appVersion,
    String? locale,
  });
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<NotificationItem>> fetchNotifications({
    required String installationId,
    int limit = 50,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/v1/notifications',
      queryParameters: {'limit': limit},
    );
    final rows = response.data ?? const [];
    return rows
        .whereType<Map>()
        .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
        .where((n) => n.id.isNotEmpty)
        .toList();
  }

  @override
  Future<int> fetchUnreadCount(String installationId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/notifications/unread-count',
    );
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> markRead({
    required String installationId,
    required String notificationId,
  }) async {
    await _dio.post<void>(
      '/api/v1/notifications/$notificationId/read',
    );
  }

  @override
  Future<void> markAllRead(String installationId) async {
    await _dio.post<void>(
      '/api/v1/notifications/read-all',
    );
  }

  @override
  Future<void> registerDevice({
    required String installationId,
    required String fcmToken,
    required int platform,
    required String locale,
    String? appVersion,
  }) async {
    await _dio.post<void>(
      '/api/v1/devices/register',
      data: {
        'installationId': installationId,
        'fcmToken': fcmToken,
        'platform': platform,
        'locale': locale,
        'appVersion': appVersion,
      },
    );
  }

  @override
  Future<void> updateToken({
    required String installationId,
    required String fcmToken,
    String? appVersion,
    String? locale,
  }) async {
    await _dio.put<void>(
      '/api/v1/devices/$installationId/token',
      data: {
        'fcmToken': fcmToken,
        'appVersion': appVersion,
        'locale': locale,
      },
    );
  }
}

/// Client HTTP dédié à l'API notifications (base URL séparée du site).
Dio createNotificationsApiDio() {
  final baseUrl = notificationsApiBaseUrl;
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    ),
  );
  dio.interceptors.add(notificationsAuthInterceptor());
  return dio;
}
