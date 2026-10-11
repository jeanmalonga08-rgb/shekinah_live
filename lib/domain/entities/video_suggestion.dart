import 'cantique.dart';
import 'multimedia_video.dart';

enum VideoRelatedKind { predication, cantique, multimedia }

class VideoSuggestion {
  const VideoSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.videoId,
    required this.kind,
    this.thumbnailUrl,
    this.provider = CantiqueVideoProvider.vimeo,
    this.videoEmbedUrl,
    this.predicationType,
    this.cantiqueCategory,
    this.multimediaCategory,
    this.date,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? thumbnailUrl;
  final String videoId;
  final CantiqueVideoProvider provider;
  final String? videoEmbedUrl;
  final VideoRelatedKind kind;
  final String? predicationType;
  final String? cantiqueCategory;
  final MultimediaVideoCategory? multimediaCategory;
  final DateTime? date;
}

class VideoRelatedQuery {
  const VideoRelatedQuery({
    required this.kind,
    required this.excludeId,
    this.title,
    this.date,
    this.predicationType,
    this.cantiqueCategory,
    this.multimediaCategory,
  });

  final VideoRelatedKind kind;
  final String excludeId;
  final String? title;
  final DateTime? date;
  final String? predicationType;
  final String? cantiqueCategory;
  final MultimediaVideoCategory? multimediaCategory;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoRelatedQuery &&
          kind == other.kind &&
          excludeId == other.excludeId &&
          title == other.title &&
          date == other.date &&
          predicationType == other.predicationType &&
          cantiqueCategory == other.cantiqueCategory &&
          multimediaCategory == other.multimediaCategory;

  @override
  int get hashCode => Object.hash(
        kind,
        excludeId,
        title,
        date,
        predicationType,
        cantiqueCategory,
        multimediaCategory,
      );
}
