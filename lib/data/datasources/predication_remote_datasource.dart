import 'dart:ui';

import 'package:dio/dio.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/locale_content_resolver.dart';
import '../../core/utils/location_normalizer.dart';
import '../../core/utils/preacher_name_normalizer.dart';
import '../../domain/entities/predication.dart';

abstract class PredicationRemoteDataSource {
  Future<PredicationPage> fetchPredications({
    String query = '',
    String? year,
    List<String>? preacherVariants,
    List<String>? searchPreacherVariants,
    String? type,
    String? timeType,
    List<String>? locationVariants,
    int page = 0,
    Locale? contentLocale,
  });

  Future<NormalizedPreachers> fetchPreachers();

  Future<NormalizedLocations> fetchLocations();

  Future<List<Predication>> fetchRecentOfMonth({
    int limit = 2,
    Locale? contentLocale,
  });

  Future<List<VideoDownloadOption>> fetchVideoDownloads(String videoId);

  Future<int?> fetchVideoDuration(String videoId);

  Future<String?> fetchVimeoPlayerEmbedUrl(String videoId);

  Future<int?> fetchRemoteFileSize(String url);
}

class PredicationRemoteDataSourceImpl implements PredicationRemoteDataSource {
  PredicationRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<PredicationPage> fetchPredications({
    String query = '',
    String? year,
    List<String>? preacherVariants,
    List<String>? searchPreacherVariants,
    String? type,
    String? timeType,
    List<String>? locationVariants,
    int page = 0,
    Locale? contentLocale,
  }) async {
    final pageSize = AppConstants.predicationsPageSize;
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final queryParameters = <String, dynamic>{
      'select': '*',
      'order': 'date.desc',
    };

    final andParts = <String>[];

    if (year != null && year.isNotEmpty) {
      andParts.add('date.gte.$year-01-01');
      andParts.add('date.lte.$year-12-31');
    }

    final typeValue = type?.trim();
    if (typeValue != null && typeValue.isNotEmpty) {
      andParts.add('type.eq.$typeValue');
    }

    final timeTypeValue = timeType?.trim();
    if (timeTypeValue != null && timeTypeValue.isNotEmpty) {
      andParts.add('timeType.eq.$timeTypeValue');
    }

    final locations = _uniqueNonEmpty(locationVariants);
    if (locations.isNotEmpty) {
      final orParts = <String>[];
      final seen = <String>{};

      void addEq(String value) {
        final key = 'eq:${value.toLowerCase()}';
        if (!seen.add(key)) return;
        orParts.add('location.eq.${_quoteFilterValue(value)}');
      }

      for (final loc in locations) {
        addEq(loc);
      }

      if (orParts.length == 1) {
        andParts.add(orParts.first);
      } else if (orParts.isNotEmpty) {
        andParts.add('or(${orParts.join(',')})');
      }
    }

    final ministers = _uniqueNonEmpty(preacherVariants);
    if (ministers.isNotEmpty) {
      // Même logique que la barre de recherche : ilike (casse/accents) + eq
      // sur chaque variante brute en base.
      final orParts = <String>[];
      final seen = <String>{};

      void addEq(String value) {
        final key = 'eq:${value.toLowerCase()}';
        if (!seen.add(key)) return;
        orParts.add('minister.eq.${_quoteFilterValue(value)}');
      }

      void addIlike(String pattern) {
        final p = pattern
            .trim()
            .replaceAll(',', ' ')
            .replaceAll('%', '')
            .replaceAll('*', '');
        if (p.isEmpty) return;
        final key = 'ilike:${p.toLowerCase()}';
        if (!seen.add(key)) return;
        orParts.add('minister.ilike.*$p*');
      }

      for (final m in ministers) {
        addEq(m);
        addIlike(m);
        addIlike(PreacherNameNormalizer.fingerprint(m));
      }

      if (orParts.length == 1) {
        andParts.add(orParts.first);
      } else if (orParts.isNotEmpty) {
        andParts.add('or(${orParts.join(',')})');
      }
    }

    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final q = trimmed.replaceAll(',', ' ').replaceAll('%', '');
      final orParts = <String>[
        'title->>fr.ilike.*$q*',
        'title->>en.ilike.*$q*',
        'title->>pr.ilike.*$q*',
        'minister.ilike.*$q*',
        'location.ilike.*$q*',
      ];
      for (final variant in _uniqueNonEmpty(searchPreacherVariants)) {
        final v = variant.replaceAll(',', ' ').replaceAll('%', '');
        if (v.isEmpty) continue;
        orParts.add('minister.eq.${_quoteFilterValue(v)}');
      }
      andParts.add('or(${orParts.join(',')})');
    }

    if (andParts.isNotEmpty) {
      queryParameters['and'] = '(${andParts.join(',')})';
    }

    final response = await dio.get<List<dynamic>>(
      '${AppConstants.supabaseUrl}/rest/v1/${AppConstants.sermonArchivesTable}',
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
          'Prefer': 'count=exact',
          'Range': '$from-$to',
          'User-Agent': AppConstants.userAgent,
        },
        connectTimeout:
            Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    final total = _parseTotalCount(response.headers.value('content-range'));
    final rows = response.data ?? const [];
    final items = rows
        .whereType<Map>()
        .map(
          (row) => _mapPredication(
            Map<String, dynamic>.from(row),
            contentLocale,
          ),
        )
        .toList();

    return PredicationPage(
      items: items,
      totalCount: total,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<NormalizedPreachers> fetchPreachers() async {
    final names = <String>{};
    var from = 0;
    const pageSize = 1000;

    while (true) {
      final to = from + pageSize - 1;
      final response = await dio.get<List<dynamic>>(
        '${AppConstants.supabaseUrl}/rest/v1/${AppConstants.sermonArchivesTable}',
        queryParameters: {
          'select': 'minister',
          'minister': 'not.is.null',
          'order': 'minister.asc',
        },
        options: Options(
          headers: {
            'apikey': AppConstants.supabaseAnonKey,
            'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
            'Range': '$from-$to',
            'User-Agent': AppConstants.userAgent,
          },
          connectTimeout:
              Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout:
              Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );

      final rows = response.data ?? const [];
      if (rows.isEmpty) break;

      for (final row in rows.whereType<Map>()) {
        final minister = (row['minister'] ?? '').toString().trim();
        if (minister.isNotEmpty) names.add(minister);
      }

      if (rows.length < pageSize) break;
      from += pageSize;
    }

    return PreacherNameNormalizer.normalize(names);
  }

  @override
  Future<NormalizedLocations> fetchLocations() async {
    final locations = <String>{};
    var from = 0;
    const pageSize = 1000;

    while (true) {
      final to = from + pageSize - 1;
      final response = await dio.get<List<dynamic>>(
        '${AppConstants.supabaseUrl}/rest/v1/${AppConstants.sermonArchivesTable}',
        queryParameters: {
          'select': 'location',
          'location': 'not.is.null',
          'order': 'location.asc',
        },
        options: Options(
          headers: {
            'apikey': AppConstants.supabaseAnonKey,
            'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
            'Range': '$from-$to',
            'User-Agent': AppConstants.userAgent,
          },
          connectTimeout:
              Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout:
              Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );

      final rows = response.data ?? const [];
      if (rows.isEmpty) break;

      for (final row in rows.whereType<Map>()) {
        final location = (row['location'] ?? '').toString().trim();
        if (location.isNotEmpty) locations.add(location);
      }

      if (rows.length < pageSize) break;
      from += pageSize;
    }

    return LocationNormalizer.normalize(locations);
  }

  @override
  Future<List<Predication>> fetchRecentOfMonth({
    int limit = 2,
    Locale? contentLocale,
  }) async {
    final ofMonth = await _fetchRecentPredications(
      limit: limit,
      contentLocale: contentLocale,
      currentMonthOnly: true,
    );
    if (ofMonth.length >= limit) {
      return ofMonth.take(limit).toList();
    }

    // Pas assez de prédications ce mois-ci : bascule sur les plus récentes.
    final recent = await _fetchRecentPredications(
      limit: limit,
      contentLocale: contentLocale,
      currentMonthOnly: false,
    );
    return recent.take(limit).toList();
  }

  Future<List<Predication>> _fetchRecentPredications({
    required int limit,
    required bool currentMonthOnly,
    Locale? contentLocale,
  }) async {
    final queryParameters = <String, dynamic>{
      'select': '*',
      'order': 'date.desc',
      'limit': '$limit',
    };

    if (currentMonthOnly) {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year.toString();
      final lastDay = DateTime(now.year, now.month + 1, 0)
          .day
          .toString()
          .padLeft(2, '0');
      queryParameters['and'] =
          '(date.gte.$year-$month-01,date.lte.$year-$month-$lastDay)';
    }

    final response = await dio.get<List<dynamic>>(
      '${AppConstants.supabaseUrl}/rest/v1/${AppConstants.sermonArchivesTable}',
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
          'User-Agent': AppConstants.userAgent,
        },
        connectTimeout:
            Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout:
            Duration(milliseconds: AppConstants.receiveTimeout),
      ),
    );

    final rows = response.data ?? const [];
    return rows
        .whereType<Map>()
        .map(
          (row) => _mapPredication(
            Map<String, dynamic>.from(row),
            contentLocale,
          ),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<int?> fetchVideoDuration(String videoId) async {
    final trimmed = videoId.trim();
    if (trimmed.isEmpty) return null;
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${AppConstants.notificationsApiBaseUrl}/api/v1/vimeo/videos/$trimmed',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          connectTimeout:
              Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );
      final seconds = _asInt(response.data?['duration']);
      return seconds > 0 ? seconds : null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> fetchVimeoPlayerEmbedUrl(String videoId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${AppConstants.notificationsApiBaseUrl}/api/v1/vimeo/videos/$videoId',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          connectTimeout:
              Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );
      final url = response.data?['player_embed_url']?.toString().trim();
      if (url == null || url.isEmpty) return null;
      return url;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<VideoDownloadOption>> fetchVideoDownloads(String videoId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${AppConstants.notificationsApiBaseUrl}/api/v1/vimeo/videos/$videoId',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          connectTimeout:
              Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );

      final durationSeconds = _asInt(response.data?['duration']);
      final downloads = response.data?['download'];
      if (downloads is! List || downloads.isEmpty) {
        // Pas de fichier téléchargeable, mais la durée reste utile pour l'UI.
        if (durationSeconds > 0) {
          return [
            VideoDownloadOption(
              label: 'stream',
              url: '',
              width: 0,
              height: 0,
              durationSeconds: durationSeconds,
            ),
          ];
        }
        return const [];
      }

      final options = <VideoDownloadOption>[];
      for (final item in downloads) {
        if (item is! Map) continue;
        final link = item['link']?.toString();
        final width = _asInt(item['width']);
        final height = _asInt(item['height']);
        if (link == null || link.isEmpty || width == 0) continue;
        options.add(
          VideoDownloadOption(
            label: '${width}x$height',
            url: link,
            width: width,
            height: height,
            sizeBytes: _asInt(item['size']),
            durationSeconds: durationSeconds > 0 ? durationSeconds : null,
          ),
        );
      }

      options.sort((a, b) => b.width.compareTo(a.width));
      if (options.isEmpty && durationSeconds > 0) {
        return [
          VideoDownloadOption(
            label: 'stream',
            url: '',
            width: 0,
            height: 0,
            durationSeconds: durationSeconds,
          ),
        ];
      }
      return options;
    } on DioException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<int?> fetchRemoteFileSize(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('http')) return null;
    try {
      final response = await dio.head<void>(
        trimmed,
        options: Options(
          followRedirects: true,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
          headers: {'User-Agent': AppConstants.userAgent},
          receiveTimeout:
              Duration(milliseconds: AppConstants.receiveTimeout),
        ),
      );
      final raw = response.headers.value('content-length');
      final size = int.tryParse(raw ?? '');
      if (size == null || size <= 0) return null;
      return size;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Predication _mapPredication(
    Map<String, dynamic> json,
    Locale? contentLocale,
  ) {
    final titleMap = _asStringMap(json['title']);
    final videoMap = _asStringMap(json['videoLink'] ?? json['videoLink']);
    final audioMap = _asStringMap(json['audioLink'] ?? json['audioLink']);
    final ministerRaw =
        (json['minister'] ?? json['minister'] ?? '').toString().trim();
    final parts = ministerRaw.split(RegExp(r'\s+'));
    final titlePart = parts.isNotEmpty ? parts.first : '';
    final namePart =
        parts.length > 1 ? parts.sublist(1).join(' ') : ministerRaw;

    return Predication(
      id: (json['id'] ?? '').toString(),
      title: _localized(titleMap, contentLocale),
      preacher: namePart,
      preacherTitle: titlePart,
      date: DateTime.tryParse((json['date'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      location: (json['location'] ?? json['location'] ?? '').toString(),
      type: (json['type'] ?? 'GENERAL').toString(),
      timeType: (json['timeType'] ?? json['timeType'] ?? 'AM').toString(),
      thumbnailUrl: _nullableString(json['thumbnail'] ?? json['thumbnail']),
      videoIdFr: _nullableString(videoMap['fr']),
      videoIdEn: _nullableString(videoMap['en']),
      videoIdPr: _nullableString(videoMap['pr']),
      videoIdFrOnly: _nullableString(videoMap['frOnly']),
      audioUrlFr: _nullableString(audioMap['fr']),
      audioUrlEn: _nullableString(audioMap['en']),
      audioUrlPr: _nullableString(audioMap['pr']),
      audioUrlFrOnly: _nullableString(audioMap['frOnly']),
    );
  }

  String _localized(Map<String, String> map, Locale? contentLocale) {
    if (contentLocale != null) {
      return pickLocalizedMap(map, contentLocale);
    }
    for (final key in ['fr', 'en', 'pr']) {
      final value = map[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  Map<String, String> _asStringMap(dynamic value) {
    if (value is! Map) return {};
    return value.map(
      (key, dynamic v) => MapEntry(key.toString(), v?.toString() ?? ''),
    );
  }

  String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  /// Quotes a PostgREST filter value (spaces / reserved chars).
  String _quoteFilterValue(String value) {
    final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    return '"$escaped"';
  }

  List<String> _uniqueNonEmpty(List<String>? values) {
    if (values == null || values.isEmpty) return const [];
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) continue;
      result.add(trimmed);
    }
    return result;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _parseTotalCount(String? contentRange) {
    if (contentRange == null) return 0;
    final parts = contentRange.split('/');
    if (parts.length != 2) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }
}
