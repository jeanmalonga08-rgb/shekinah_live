import 'package:dio/dio.dart';

import '../../core/network/notifications_api_config.dart';
import '../../domain/entities/app_update_info.dart';

abstract class AppUpdateRemoteDataSource {
  Future<AppUpdateInfo?> fetchUpdateInfo();
}

class AppUpdateRemoteDataSourceImpl implements AppUpdateRemoteDataSource {
  AppUpdateRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? _createPublicApiDio();

  final Dio _dio;

  static Dio _createPublicApiDio() {
    return Dio(
      BaseOptions(
        baseUrl: notificationsApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
  }

  @override
  Future<AppUpdateInfo?> fetchUpdateInfo() async {
    if (!notificationsApiEnabled) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/app/version',
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;

      final info = AppUpdateInfo.fromJson(data);
      if (info.latestVersion.isEmpty) return null;
      return info;
    } catch (_) {
      return null;
    }
  }
}
