import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/offline_storage_service.dart';
import '../../domain/entities/offline_media.dart';

final offlineStorageServiceProvider = Provider<OfflineStorageService>(
  (ref) => OfflineStorageService(),
);

final offlineMediaProvider =
    AsyncNotifierProvider<OfflineMediaNotifier, List<OfflineMediaItem>>(
  OfflineMediaNotifier.new,
);

class OfflineMediaNotifier extends AsyncNotifier<List<OfflineMediaItem>> {
  @override
  Future<List<OfflineMediaItem>> build() {
    return ref.read(offlineStorageServiceProvider).loadIndex();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(offlineStorageServiceProvider).loadIndex(),
    );
  }

  Future<OfflineMediaItem> download({
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
    final service = ref.read(offlineStorageServiceProvider);
    final item = await service.downloadFromUrl(
      category: category,
      format: format,
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      url: url,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
      expectedSizeBytes: expectedSizeBytes,
      resume: resume,
      cancelToken: cancelToken,
      onProgress: onProgress,
      extraHeaders: extraHeaders,
      fileExtension: fileExtension,
    );
    await refresh();
    return item;
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
    final service = ref.read(offlineStorageServiceProvider);
    final item = await service.downloadYoutubeVideo(
      category: category,
      sourceId: sourceId,
      videoId: videoId,
      title: title,
      subtitle: subtitle,
      thumbnailUrl: thumbnailUrl,
      resume: resume,
      cancelToken: cancelToken,
      onProgress: onProgress,
    );
    await refresh();
    return item;
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
    final service = ref.read(offlineStorageServiceProvider);
    final item = await service.downloadYoutubeAudio(
      category: category,
      sourceId: sourceId,
      videoId: videoId,
      title: title,
      subtitle: subtitle,
      thumbnailUrl: thumbnailUrl,
      resume: resume,
      cancelToken: cancelToken,
      onProgress: onProgress,
    );
    await refresh();
    return item;
  }

  Future<void> remove(String id) async {
    await ref.read(offlineStorageServiceProvider).delete(id);
    await refresh();
  }

  List<OfflineMediaItem> byCategory(OfflineMediaCategory category) {
    return state.valueOrNull
            ?.where((e) => e.category == category)
            .toList() ??
        [];
  }
}
