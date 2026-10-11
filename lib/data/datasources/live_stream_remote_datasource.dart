import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/live_status.dart';

abstract class LiveStreamRemoteDataSource {
  Future<LiveStreamEntity> fetchLiveSettings();
}

class LiveStreamRemoteDataSourceImpl implements LiveStreamRemoteDataSource {
  LiveStreamRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<LiveStreamEntity> fetchLiveSettings() async {
    final response = await dio.get<List<dynamic>>(
      '${AppConstants.supabaseUrl}/rest/v1/${AppConstants.servicesLiveTable}',
      queryParameters: const {
        'select': '*',
        'order': 'updated_at.desc',
        'limit': '1',
      },
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
    if (rows.isEmpty) {
      return LiveStreamEntity(
        status: LiveStatus.offline,
        title: null,
        lastChecked: DateTime.now(),
      );
    }

    final row = Map<String, dynamic>.from(rows.first as Map);
    return _mapRow(row);
  }

  LiveStreamEntity _mapRow(Map<String, dynamic> row) {
    final goLive = _asInt(row['goLive']) != 0;
    final streaming = row['streaming'];
    final streamingMap = streaming is Map
        ? Map<String, dynamic>.from(streaming)
        : <String, dynamic>{};

    final videoRaw = streamingMap['videoId'];
    final audioRaw = streamingMap['audioLink'];

    final videoIds = _parseLangMap(videoRaw);
    final audioLinks = _parseLangMap(audioRaw);

    final message = (row['message'] as String?)?.trim();
    final updatedAt = _parseDateTime(row['updated_at'] ?? row['updatedAt']);

    return LiveStreamEntity(
      status: goLive ? LiveStatus.live : LiveStatus.offline,
      title: null,
      message: (message == null || message.isEmpty) ? null : message,
      videoIds: videoIds,
      audioLinks: audioLinks,
      lastChecked: DateTime.now(),
      liveStartedAt: goLive ? updatedAt : null,
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  Map<LiveLang, String> _parseLangMap(dynamic raw) {
    if (raw is! Map) return const {};
    final map = Map<String, dynamic>.from(raw);
    final result = <LiveLang, String>{};

    void put(LiveLang lang, String key) {
      final value = map[key];
      if (value is! String) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      result[lang] = trimmed;
    }

    put(LiveLang.fr, 'fr');
    put(LiveLang.en, 'en');
    put(LiveLang.pr, 'pr');
    return result;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is bool) return value ? 1 : 0;
    return 0;
  }
}
