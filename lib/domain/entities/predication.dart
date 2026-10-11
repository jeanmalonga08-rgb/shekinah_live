class Predication {
  const Predication({
    required this.id,
    required this.title,
    required this.preacher,
    required this.preacherTitle,
    required this.date,
    required this.location,
    required this.type,
    required this.timeType,
    this.thumbnailUrl,
    this.videoIdFr,
    this.videoIdEn,
    this.videoIdPr,
    this.videoIdFrOnly,
    this.audioUrlFr,
    this.audioUrlEn,
    this.audioUrlPr,
    this.audioUrlFrOnly,
  });

  final String id;
  final String title;
  final String preacher;
  final String preacherTitle;
  final DateTime date;
  final String location;
  final String type;
  final String timeType;
  final String? thumbnailUrl;
  final String? videoIdFr;
  final String? videoIdEn;
  final String? videoIdPr;
  final String? videoIdFrOnly;
  final String? audioUrlFr;
  final String? audioUrlEn;
  final String? audioUrlPr;
  final String? audioUrlFrOnly;

  String get displayPreacher {
    final title = preacherTitle.trim();
    final name = preacher.trim();
    if (title.isEmpty) return name;
    if (name.isEmpty) return title;
    return '$title $name';
  }

  String? get primaryVideoId {
    for (final id in [videoIdFr, videoIdFrOnly, videoIdEn, videoIdPr]) {
      if (id != null && id.trim().isNotEmpty) return id.trim();
    }
    return null;
  }

  String? get primaryAudioUrl {
    for (final url in [audioUrlFr, audioUrlFrOnly, audioUrlEn, audioUrlPr]) {
      if (url != null && url.trim().startsWith('http')) return url.trim();
    }
    return null;
  }

  bool get hasVideo => primaryVideoId != null;
  bool get hasAudio => primaryAudioUrl != null;
}

class VideoDownloadOption {
  const VideoDownloadOption({
    required this.label,
    required this.url,
    required this.width,
    required this.height,
    this.sizeBytes = 0,
    this.durationSeconds,
  });

  final String label;
  final String url;
  final int width;
  final int height;
  final int sizeBytes;
  final int? durationSeconds;
}

class PredicationPage {
  const PredicationPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<Predication> items;
  final int totalCount;
  final int page;
  final int pageSize;

  bool get hasMore => (page + 1) * pageSize < totalCount;
}
