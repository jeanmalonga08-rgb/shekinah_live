import 'package:dio/dio.dart';

import '../../core/network/notifications_api_config.dart';
import '../../domain/entities/audio_conversion_job.dart';
import '../datasources/notifications_remote_datasource.dart';

class AudioConversionApiException implements Exception {
  AudioConversionApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  final String message;
  final String? errorCode;
  final int? statusCode;

  @override
  String toString() => message;
}

class AudioConversionApiService {
  AudioConversionApiService({Dio? dio})
      : _dio = dio ?? createNotificationsApiDio();

  final Dio _dio;

  bool get isEnabled => notificationsApiEnabled;

  Future<AudioConversionJob> startConversion({
    required String mediaId,
    required String provider,
    required String videoId,
    required AudioConversionProfile profile,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/media/${Uri.encodeComponent(mediaId)}/audio-conversion',
        data: {
          'provider': provider,
          'videoId': videoId,
          'profile': profile.apiValue,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (s) => s != null && s >= 200 && s < 500,
        ),
      );

      final data = response.data;
      if (response.statusCode != null &&
          response.statusCode! >= 400) {
        throw AudioConversionApiException(
          message: data?['message']?.toString() ??
              'Conversion impossible (${response.statusCode}).',
          errorCode: data?['errorCode']?.toString(),
          statusCode: response.statusCode,
        );
      }

      if (data == null) {
        throw AudioConversionApiException(message: 'Réponse vide.');
      }
      return AudioConversionJob.fromJson(data);
    } on AudioConversionApiException {
      rethrow;
    } on DioException catch (e) {
      final data = e.response?.data;
      String? code;
      String? msg;
      if (data is Map) {
        code = data['errorCode']?.toString();
        msg = data['message']?.toString() ?? data['error']?.toString();
      }
      throw AudioConversionApiException(
        message: msg ?? 'Impossible de démarrer la conversion.',
        errorCode: code,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<AudioConversionJob> getStatus(String jobId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/audio-conversion/${Uri.encodeComponent(jobId)}',
      );
      final data = response.data;
      if (data == null) {
        throw AudioConversionApiException(message: 'Réponse vide.');
      }
      return AudioConversionJob.fromJson(data);
    } on DioException catch (e) {
      throw AudioConversionApiException(
        message: 'Statut de conversion indisponible.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> cancel(String jobId) async {
    try {
      await _dio.post<void>(
        '/api/v1/audio-conversion/${Uri.encodeComponent(jobId)}/cancel',
      );
    } catch (_) {
      // best-effort
    }
  }

  /// URL absolue du fichier audio (avec auth via headers au téléchargement).
  String resolveDownloadUrl(String? relativeOrAbsolute) {
    if (relativeOrAbsolute == null || relativeOrAbsolute.isEmpty) {
      return '';
    }
    if (relativeOrAbsolute.startsWith('http')) return relativeOrAbsolute;
    final base = notificationsApiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final path = relativeOrAbsolute.startsWith('/')
        ? relativeOrAbsolute
        : '/$relativeOrAbsolute';
    return '$base$path';
  }

  Future<AudioConversionJob> waitUntilComplete(
    String jobId, {
    Duration pollInterval = const Duration(seconds: 3),
    void Function(AudioConversionJob job)? onProgress,
    CancelToken? cancelToken,
  }) async {
    while (true) {
      if (cancelToken?.isCancelled == true) {
        throw AudioConversionApiException(
          message: 'Conversion annulée.',
          errorCode: 'CANCELLED',
        );
      }
      final job = await getStatus(jobId);
      onProgress?.call(job);
      if (job.status.isTerminal) return job;
      await Future<void>.delayed(pollInterval);
    }
  }
}
