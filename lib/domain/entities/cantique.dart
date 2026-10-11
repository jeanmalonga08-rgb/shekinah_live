enum CantiqueVideoProvider {
  vimeo,
  youtube,
}

class Cantique {
  const Cantique({
    required this.id,
    required this.number,
    required this.title,
    required this.category,
    this.audioUrl,
    this.videoId,
    this.videoEmbedUrl,
    this.videoProvider,
    this.coverUrl,
    this.performer,
    this.isVideoOnly = false,
  });

  final String id;
  final int number;
  final String title;
  final String category;
  final String? audioUrl;
  final String? videoId;
  final String? videoEmbedUrl;
  final CantiqueVideoProvider? videoProvider;
  final String? coverUrl;
  final String? performer;
  final bool isVideoOnly;

  bool get hasAudio =>
      audioUrl != null && audioUrl!.trim().startsWith('http');
  bool get hasVideo => videoId != null && videoId!.trim().isNotEmpty;

  String get displaySubtitle {
    final who = performer?.trim();
    if (who != null && who.isNotEmpty) return who;
    return category;
  }
}
