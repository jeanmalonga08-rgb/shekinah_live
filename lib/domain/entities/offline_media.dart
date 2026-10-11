enum OfflineMediaCategory {
  predication,
  cantique,
  ceremony,
  documentaire,
  recueilCantique,
  libraryPepite,
  libraryPublication,
}

enum OfflineMediaFormat { audio, video, pdf }

class OfflineMediaItem {
  const OfflineMediaItem({
    required this.id,
    required this.category,
    required this.format,
    required this.sourceId,
    required this.title,
    required this.subtitle,
    required this.localPath,
    required this.fileSizeBytes,
    required this.downloadedAt,
    this.thumbnailUrl,
    this.durationSeconds,
  });

  final String id;
  final OfflineMediaCategory category;
  final OfflineMediaFormat format;
  final String sourceId;
  final String title;
  final String subtitle;
  final String localPath;
  final int fileSizeBytes;
  final DateTime downloadedAt;
  final String? thumbnailUrl;
  final int? durationSeconds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'format': format.name,
        'sourceId': sourceId,
        'title': title,
        'subtitle': subtitle,
        'localPath': localPath,
        'fileSizeBytes': fileSizeBytes,
        'downloadedAt': downloadedAt.toIso8601String(),
        'thumbnailUrl': thumbnailUrl,
        'durationSeconds': durationSeconds,
      };

  factory OfflineMediaItem.fromJson(Map<String, dynamic> json) {
    return OfflineMediaItem(
      id: json['id'] as String,
      category: OfflineMediaCategory.values.byName(json['category'] as String),
      format: OfflineMediaFormat.values.byName(json['format'] as String),
      sourceId: json['sourceId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      localPath: json['localPath'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }

  OfflineMediaItem copyWith({
    int? fileSizeBytes,
    int? durationSeconds,
    String? localPath,
  }) {
    return OfflineMediaItem(
      id: id,
      category: category,
      format: format,
      sourceId: sourceId,
      title: title,
      subtitle: subtitle,
      localPath: localPath ?? this.localPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      downloadedAt: downloadedAt,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  static String buildId({
    required OfflineMediaCategory category,
    required String sourceId,
    required OfflineMediaFormat format,
  }) {
    return '${category.name}_${sourceId}_${format.name}';
  }
}
