import 'offline_media.dart';

enum OfflineDownloadKind { url, youtube }

/// Métadonnées d'un téléchargement (file d'attente / reprise).
class PendingOfflineDownload {
  const PendingOfflineDownload({
    required this.category,
    required this.format,
    required this.sourceId,
    required this.title,
    required this.subtitle,
    this.url,
    this.videoId,
    this.thumbnailUrl,
    this.kind = OfflineDownloadKind.url,
    this.durationSeconds,
    this.expectedSizeBytes,
    this.extraHeaders,
    this.fileExtension,
  });

  final OfflineMediaCategory category;
  final OfflineMediaFormat format;
  final String sourceId;
  final String title;
  final String subtitle;
  final String? url;
  final String? videoId;
  final String? thumbnailUrl;
  final OfflineDownloadKind kind;
  final int? durationSeconds;
  final int? expectedSizeBytes;
  final Map<String, String>? extraHeaders;
  final String? fileExtension;

  String get downloadId => OfflineMediaItem.buildId(
        category: category,
        sourceId: sourceId,
        format: format,
      );

  bool matches({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) {
    return this.category == category &&
        this.sourceId == sourceId &&
        this.format == format;
  }

  PendingOfflineDownload copyWith({
    String? url,
    String? videoId,
    String? thumbnailUrl,
    int? durationSeconds,
    int? expectedSizeBytes,
    Map<String, String>? extraHeaders,
    String? fileExtension,
  }) {
    return PendingOfflineDownload(
      category: category,
      format: format,
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      url: url ?? this.url,
      videoId: videoId ?? this.videoId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      kind: kind,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      expectedSizeBytes: expectedSizeBytes ?? this.expectedSizeBytes,
      extraHeaders: extraHeaders ?? this.extraHeaders,
      fileExtension: fileExtension ?? this.fileExtension,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'format': format.name,
        'sourceId': sourceId,
        'title': title,
        'subtitle': subtitle,
        'url': url,
        'videoId': videoId,
        'thumbnailUrl': thumbnailUrl,
        'kind': kind.name,
        'durationSeconds': durationSeconds,
        'expectedSizeBytes': expectedSizeBytes,
        'extraHeaders': extraHeaders,
        'fileExtension': fileExtension,
      };

  factory PendingOfflineDownload.fromJson(Map<String, dynamic> json) {
    Map<String, String>? headers;
    final rawHeaders = json['extraHeaders'];
    if (rawHeaders is Map) {
      headers = rawHeaders.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    }
    return PendingOfflineDownload(
      category: OfflineMediaCategory.values.byName(json['category'] as String),
      format: OfflineMediaFormat.values.byName(json['format'] as String),
      sourceId: json['sourceId'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      url: json['url'] as String?,
      videoId: json['videoId'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      kind: OfflineDownloadKind.values.byName(
        json['kind'] as String? ?? OfflineDownloadKind.url.name,
      ),
      durationSeconds: json['durationSeconds'] as int?,
      expectedSizeBytes: json['expectedSizeBytes'] as int?,
      extraHeaders: headers,
      fileExtension: json['fileExtension'] as String?,
    );
  }
}
