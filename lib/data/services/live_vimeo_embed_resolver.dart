import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';

/// Résout un ID d'événement Vimeo Live vers l'URL légère `player.vimeo.com`
/// (même lecteur que les prédications), plus fiable en WebView mobile.
class LiveVimeoEmbedResolver {
  LiveVimeoEmbedResolver({required this.dio});

  final Dio dio;

  String? _cachedSource;
  String? _cachedResolved;
  DateTime? _cachedAt;

  static const _cacheTtl = Duration(seconds: 45);
  static final _playerVideoIdPattern = RegExp(
    r'player\.vimeo\.com/video/(\d+)',
  );
  static final _eventIdPattern = RegExp(r'/event/(\d+)');

  Future<String> resolve(String source) async {
    final trimmed = source.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.contains('player.vimeo.com/video/')) {
      return trimmed;
    }

    final eventId = _eventIdFrom(trimmed);
    if (eventId == null) {
      return trimmed.startsWith('http') ? trimmed : trimmed;
    }

    if (_cachedSource == eventId &&
        _cachedResolved != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cachedResolved!;
    }

    try {
      final response = await dio.get<String>(
        'https://vimeo.com/event/$eventId/embed',
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Referer': '${AppConstants.websiteUrl}/',
            'User-Agent': AppConstants.userAgent,
            'Accept': 'text/html,*/*',
          },
          connectTimeout:
              Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout:
              Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );
      final html = response.data ?? '';
      final match = _playerVideoIdPattern.firstMatch(html);
      if (match != null) {
        final resolved = 'https://player.vimeo.com/video/${match.group(1)}';
        _cachedSource = eventId;
        _cachedResolved = resolved;
        _cachedAt = DateTime.now();
        return resolved;
      }
    } catch (_) {
      // Fallback ci-dessous.
    }

    final fallback = 'https://vimeo.com/event/$eventId/embed';
    _cachedSource = eventId;
    _cachedResolved = fallback;
    _cachedAt = DateTime.now();
    return fallback;
  }

  void invalidateCache() {
    _cachedSource = null;
    _cachedResolved = null;
    _cachedAt = null;
  }

  String? _eventIdFrom(String value) {
    if (RegExp(r'^\d+$').hasMatch(value)) return value;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final fromPath = _eventIdPattern.firstMatch(uri.path)?.group(1);
    return fromPath;
  }
}
