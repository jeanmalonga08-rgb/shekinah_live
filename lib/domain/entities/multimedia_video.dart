enum MultimediaVideoCategory { documentaire, scenette, divers }

class MultimediaVideo {
  const MultimediaVideo({
    required this.id,
    required this.title,
    required this.category,
    required this.videoId,
    this.thumbnailUrl,
    this.dateLabel,
    this.embedUrl,
    this.isAvailable = true,
  });

  final String id;
  final String title;
  final MultimediaVideoCategory category;
  final String videoId;
  final String? thumbnailUrl;
  final String? dateLabel;

  /// URL player Vimeo (souvent avec hash `h=`) — à préférer pour la lecture.
  final String? embedUrl;

  /// `false` si la vidéo Vimeo est absente / cold storage / non lisible.
  final bool isAvailable;

  String get defaultThumbnailUrl =>
      thumbnailUrl ?? 'https://shekinahgospel.org/images/music/eagle_0.png';
}
