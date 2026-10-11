import 'package:dio/dio.dart';
import '../../domain/entities/offline_media.dart';

class OfflineVideoUnavailableException implements Exception {
  const OfflineVideoUnavailableException();
}

class OfflineStorageUnsupportedException implements Exception {
  const OfflineStorageUnsupportedException();
}

/// Stockage hors ligne indisponible sur le Web (navigateur).
class OfflineStorageService {
  OfflineStorageService({Dio? dio});

  Future<List<OfflineMediaItem>> loadIndex() async => [];

  Future<bool> exists({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) async =>
      false;

  Future<OfflineMediaItem> downloadFromUrl({
    required OfflineMediaCategory category,
    required OfflineMediaFormat format,
    required String sourceId,
    required String title,
    required String subtitle,
    required String url,
    String? thumbnailUrl,
    int? durationSeconds,
    int? expectedSizeBytes,
    bool resume = true,
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
    Map<String, String>? extraHeaders,
    String? fileExtension,
  }) async {
    throw const OfflineStorageUnsupportedException();
  }

  Future<OfflineMediaItem> downloadYoutubeVideo({
    required OfflineMediaCategory category,
    required String sourceId,
    required String videoId,
    required String title,
    required String subtitle,
    String? thumbnailUrl,
    bool resume = true,
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    throw const OfflineStorageUnsupportedException();
  }

  Future<OfflineMediaItem> downloadYoutubeAudio({
    required OfflineMediaCategory category,
    required String sourceId,
    required String videoId,
    required String title,
    required String subtitle,
    String? thumbnailUrl,
    bool resume = true,
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    throw const OfflineStorageUnsupportedException();
  }

  Future<void> deletePartial({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
    String? url,
  }) async {}

  Future<void> delete(String id) async {}

  Future<int> totalBytes() async => 0;
}
