import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/offline_media.dart';
import '../pages/offline_media_player_page.dart';
import '../pages/predication_audio_page.dart';
import '../pages/predication_video_page.dart';
import '../providers/offline_media_provider.dart';
import '../../domain/entities/cantique.dart';
import '../../domain/entities/multimedia_video.dart';
import '../../domain/entities/video_suggestion.dart';

OfflineMediaItem? findOfflineItem(
  WidgetRef ref, {
  required OfflineMediaCategory category,
  required String sourceId,
  required OfflineMediaFormat format,
}) {
  final id = OfflineMediaItem.buildId(
    category: category,
    sourceId: sourceId,
    format: format,
  );
  final items = ref.read(offlineMediaProvider).valueOrNull ?? const [];
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

bool hasOfflineMedia(
  WidgetRef ref, {
  required OfflineMediaCategory category,
  required String sourceId,
  required OfflineMediaFormat format,
}) {
  return findOfflineItem(
        ref,
        category: category,
        sourceId: sourceId,
        format: format,
      ) !=
      null;
}

void openOfflinePlayer(
  BuildContext context,
  OfflineMediaItem item, {
  List<OfflineMediaItem>? playlist,
}) {
  final list = playlist ?? [item];
  final index = list.indexWhere((e) => e.id == item.id);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => OfflineMediaPlayerPage(
        playlist: list,
        initialIndex: index < 0 ? 0 : index,
      ),
    ),
  );
}

/// Ouvre le lecteur hors ligne avec toute la file de la même catégorie / format.
void openOfflinePlayerWithQueue(
  BuildContext context,
  WidgetRef ref,
  OfflineMediaItem item,
) {
  final all = ref.read(offlineMediaProvider).valueOrNull ?? const [];
  final queue = all
      .where((e) => e.category == item.category && e.format == item.format)
      .toList();
  openOfflinePlayer(
    context,
    item,
    playlist: queue.isEmpty ? [item] : queue,
  );
}

void playPredicationAudioSmart(
  BuildContext context,
  WidgetRef ref, {
  required String sourceId,
  required String title,
  required String subtitle,
  required String? audioUrl,
  required String? thumbnailUrl,
  String? thumbnailAsset,
  OfflineMediaCategory category = OfflineMediaCategory.predication,
}) {
  final offline = findOfflineItem(
    ref,
    category: category,
    sourceId: sourceId,
    format: OfflineMediaFormat.audio,
  );
  if (offline != null) {
    openOfflinePlayerWithQueue(context, ref, offline);
    return;
  }
  if (audioUrl == null) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PredicationAudioPage(
        title: title,
        preacher: subtitle,
        audioUrl: audioUrl,
        thumbnailUrl: thumbnailUrl,
        thumbnailAsset: thumbnailAsset,
      ),
    ),
  );
}

void playPredicationVideoSmart(
  BuildContext context,
  WidgetRef ref, {
  required String sourceId,
  required String title,
  required String? videoId,
  CantiqueVideoProvider? cantiqueProvider,
  String? embedUrl,
  OfflineMediaCategory category = OfflineMediaCategory.predication,
  String? predicationType,
  String? cantiqueCategory,
  MultimediaVideoCategory? multimediaCategory,
  DateTime? date,
}) {
  final offline = findOfflineItem(
    ref,
    category: category,
    sourceId: sourceId,
    format: OfflineMediaFormat.video,
  );
  if (offline != null) {
    openOfflinePlayerWithQueue(context, ref, offline);
    return;
  }
  if (videoId == null || videoId.isEmpty) return;

  final relatedKind = switch (category) {
    OfflineMediaCategory.cantique => VideoRelatedKind.cantique,
    OfflineMediaCategory.documentaire => VideoRelatedKind.multimedia,
    OfflineMediaCategory.predication ||
    OfflineMediaCategory.ceremony ||
    OfflineMediaCategory.recueilCantique ||
    OfflineMediaCategory.libraryPepite ||
    OfflineMediaCategory.libraryPublication =>
      VideoRelatedKind.predication,
  };

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PredicationVideoPage(
        title: title,
        videoId: videoId,
        provider: cantiqueProvider ?? CantiqueVideoProvider.vimeo,
        embedUrl: embedUrl,
        sourceId: sourceId,
        relatedKind: relatedKind,
        relatedTitle: title,
        relatedDate: date,
        predicationType: predicationType,
        cantiqueCategory: cantiqueCategory,
        multimediaCategory: multimediaCategory,
      ),
    ),
  );
}
