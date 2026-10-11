import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/offline_media.dart';

class OfflineVideoUnavailableException implements Exception {
  const OfflineVideoUnavailableException();
}

class OfflineStorageUnsupportedException implements Exception {
  const OfflineStorageUnsupportedException();
}

class OfflineStorageService {
  OfflineStorageService({Dio? dio}) : _dio = dio ?? Dio();

  static const _indexKey = 'offline_media_index_v1';

  final Dio _dio;

  Future<Directory> get _rootDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/offline');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<OfflineMediaItem>> loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_indexKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => OfflineMediaItem.fromJson(Map<String, dynamic>.from(e)))
          .where((item) => File(item.localPath).existsSync())
          .toList()
        ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveIndex(List<OfflineMediaItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_indexKey, encoded);
  }

  Future<bool> exists({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) async {
    final id = OfflineMediaItem.buildId(
      category: category,
      sourceId: sourceId,
      format: format,
    );
    final items = await loadIndex();
    return items.any((e) => e.id == id);
  }

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
    final id = OfflineMediaItem.buildId(
      category: category,
      sourceId: sourceId,
      format: format,
    );

    final root = await _rootDir;
    final categoryDir = Directory('${root.path}/${category.name}');
    if (!await categoryDir.exists()) {
      await categoryDir.create(recursive: true);
    }

    final ext = (fileExtension != null && fileExtension.trim().isNotEmpty)
        ? (fileExtension.startsWith('.') ? fileExtension : '.$fileExtension')
        : _extensionFromUrl(url, format);
    final filePath = '${categoryDir.path}/${sourceId}_${format.name}$ext';
    final file = File(filePath);

    var existingBytes = 0;
    if (resume && await file.exists()) {
      existingBytes = await file.length();
      if (existingBytes > 0 && await _looksLikeHtmlOrEmpty(file)) {
        await file.delete();
        existingBytes = 0;
      } else if (existingBytes > 0 && existingBytes < 512) {
        await file.delete();
        existingBytes = 0;
      }
    } else if (await file.exists()) {
      await file.delete();
      existingBytes = 0;
    }

    Future<void> downloadPass({required int startBytes}) async {
      final headers = <String, dynamic>{
        'User-Agent': AppConstants.userAgent,
        'Accept': '*/*',
        'Referer': 'https://vimeo.com/',
        if (startBytes > 0) 'Range': 'bytes=$startBytes-',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _dio.get<ResponseBody>(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) =>
              status != null &&
              (status == 200 || status == 206),
          headers: headers,
          receiveTimeout: const Duration(minutes: 45),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      final status = response.statusCode ?? 0;
      if (startBytes > 0 && status == 200) {
        // Server ignored Range — restart cleanly to avoid a corrupt append.
        final sink = file.openWrite(mode: FileMode.write);
        try {
          await _pipeDownloadStream(
            response.data!.stream,
            sink,
            startBytes: 0,
            expectedSizeBytes: expectedSizeBytes,
            onProgress: onProgress,
          );
        } finally {
          await sink.close();
        }
        return;
      }

      if (startBytes == 0 && await file.exists()) {
        await file.delete();
      }

      final sink = file.openWrite(
        mode: startBytes > 0 ? FileMode.append : FileMode.write,
      );
      try {
        await _pipeDownloadStream(
          response.data!.stream,
          sink,
          startBytes: startBytes,
          expectedSizeBytes: expectedSizeBytes,
          onProgress: onProgress,
        );
      } finally {
        await sink.close();
      }
    }

    try {
      await downloadPass(startBytes: existingBytes);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      final code = e.response?.statusCode;
      // Expired CDN URL / invalid range → restart from scratch once.
      if (resume &&
          existingBytes > 0 &&
          (code == 401 || code == 403 || code == 416 || code == 404)) {
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
        return downloadFromUrl(
          category: category,
          format: format,
          sourceId: sourceId,
          title: title,
          subtitle: subtitle,
          url: url,
          thumbnailUrl: thumbnailUrl,
          durationSeconds: durationSeconds,
          expectedSizeBytes: expectedSizeBytes,
          resume: false,
          cancelToken: cancelToken,
          onProgress: onProgress,
          extraHeaders: extraHeaders,
          fileExtension: fileExtension,
        );
      }
      // Keep partial file for later resume.
      rethrow;
    }

    if (!await file.exists()) {
      throw const OfflineVideoUnavailableException();
    }

    final size = await file.length();
    if (size <= 0) {
      await file.delete();
      throw const OfflineVideoUnavailableException();
    }

    if (expectedSizeBytes != null &&
        expectedSizeBytes > 1024 &&
        size < (expectedSizeBytes * 0.5).round()) {
      // Incomplete — keep for resume.
      throw Exception(
        'Downloaded file incomplete: $size / $expectedSizeBytes bytes',
      );
    }

    if (await _looksLikeHtmlOrEmpty(file)) {
      await file.delete();
      throw Exception('Download returned an HTML/error page instead of media');
    }

    final item = OfflineMediaItem(
      id: id,
      category: category,
      format: format,
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      localPath: file.path,
      fileSizeBytes: size,
      downloadedAt: DateTime.now(),
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
    );

    final items = await loadIndex();
    final updated = [
      item,
      ...items.where((e) => e.id != id),
    ];
    await _saveIndex(updated);
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
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      if (manifest.muxed.isEmpty) {
        throw const OfflineVideoUnavailableException();
      }
      final streamInfo = _pickDataSaverMuxed(manifest.muxed);
      // Prefer HTTP download (supports Range resume) over stream copy.
      return downloadFromUrl(
        category: category,
        format: OfflineMediaFormat.video,
        sourceId: sourceId,
        title: title,
        subtitle: subtitle,
        url: streamInfo.url.toString(),
        thumbnailUrl: thumbnailUrl,
        expectedSizeBytes: streamInfo.size.totalBytes,
        resume: resume,
        cancelToken: cancelToken,
        onProgress: onProgress,
      );
    } finally {
      yt.close();
    }
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
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.audioOnly.isNotEmpty
          ? manifest.audioOnly.withHighestBitrate()
          : (manifest.muxed.isNotEmpty
              ? manifest.muxed.withHighestBitrate()
              : null);
      if (streamInfo == null) {
        throw const OfflineVideoUnavailableException();
      }
      return downloadFromUrl(
        category: category,
        format: OfflineMediaFormat.audio,
        sourceId: sourceId,
        title: title,
        subtitle: subtitle,
        url: streamInfo.url.toString(),
        thumbnailUrl: thumbnailUrl,
        expectedSizeBytes: streamInfo.size.totalBytes,
        resume: resume,
        cancelToken: cancelToken,
        onProgress: onProgress,
      );
    } finally {
      yt.close();
    }
  }

  /// Supprime un fichier partiel (annulation utilisateur).
  Future<void> deletePartial({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
    String? url,
  }) async {
    final root = await _rootDir;
    final categoryDir = Directory('${root.path}/${category.name}');
    if (!await categoryDir.exists()) return;

    final extensions = <String>{
      if (url != null) _extensionFromUrl(url, format),
      if (format == OfflineMediaFormat.audio) ...['.mp3', '.m4a', '.opus', '.mp4', '.webm'],
      if (format == OfflineMediaFormat.video) ...['.mp4', '.webm'],
      if (format == OfflineMediaFormat.pdf) '.pdf',
    };

    for (final ext in extensions) {
      final file = File('${categoryDir.path}/${sourceId}_${format.name}$ext');
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      // Legacy filename with enum toString().
      final legacy = File(
        '${categoryDir.path}/${sourceId}_$format$ext',
      );
      if (await legacy.exists()) {
        try {
          await legacy.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> delete(String id) async {
    final items = await loadIndex();
    final target = items.where((e) => e.id == id).toList();
    for (final item in target) {
      final file = File(item.localPath);
      if (await file.exists()) await file.delete();
    }
    await _saveIndex(items.where((e) => e.id != id).toList());
  }

  Future<int> totalBytes() async {
    final items = await loadIndex();
    return items.fold<int>(0, (sum, e) => sum + e.fileSizeBytes);
  }

  Future<void> _pipeDownloadStream(
    Stream<List<int>> stream,
    IOSink sink, {
    required int startBytes,
    int? expectedSizeBytes,
    void Function(int received, int total)? onProgress,
  }) async {
    var received = startBytes;
    await for (final chunk in stream) {
      sink.add(chunk);
      received += chunk.length;
      final total = expectedSizeBytes != null && expectedSizeBytes > 0
          ? expectedSizeBytes
          : -1;
      onProgress?.call(received, total);
    }
    await sink.flush();
  }

  String _extensionFromUrl(String url, OfflineMediaFormat format) {
    final uri = Uri.tryParse(url);
    final path = uri?.path.toLowerCase() ?? '';
    final lower = url.toLowerCase();
    if (path.endsWith('.pdf') || format == OfflineMediaFormat.pdf) {
      return '.pdf';
    }
    if (path.endsWith('.mp3')) return '.mp3';
    if (path.endsWith('.m4a')) return '.m4a';
    if (path.endsWith('.opus')) return '.opus';
    if (path.endsWith('.mp4')) return '.mp4';
    if (path.endsWith('.webm') ||
        lower.contains('mime=audio%2Fwebm') ||
        lower.contains('mime=audio/webm')) {
      return '.webm';
    }
    if (lower.contains('mime=audio%2Fmp4') ||
        lower.contains('mime=audio/mp4')) {
      return '.m4a';
    }
    return format == OfflineMediaFormat.audio ? '.opus' : '.mp4';
  }

  Future<bool> _looksLikeHtmlOrEmpty(File file) async {
    try {
      final length = await file.length();
      if (length <= 0) return true;
      final raf = await file.open();
      try {
        final header = await raf.read(64);
        final text = String.fromCharCodes(header).trimLeft().toLowerCase();
        return text.startsWith('<!doctype') ||
            text.startsWith('<html') ||
            text.startsWith('<head') ||
            text.startsWith('{') && text.contains('"error"');
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }
}

/// Meilleure qualité muxed ≤720p ; sinon la plus basse disponible.
MuxedStreamInfo _pickDataSaverMuxed(Iterable<MuxedStreamInfo> muxed) {
  final list = muxed.toList();
  assert(list.isNotEmpty);
  final under720 =
      list.where((s) => s.videoResolution.height <= 720).toList();
  if (under720.isNotEmpty) {
    return under720.withHighestBitrate();
  }
  list.sort(
    (a, b) => a.videoResolution.height.compareTo(b.videoResolution.height),
  );
  return list.first;
}
