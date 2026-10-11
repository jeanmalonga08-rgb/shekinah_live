import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/offline_media.dart';
import '../providers/predication_provider.dart';

/// Chips taille / type / durée pour un média en ligne ou hors ligne.
class MediaInfoChips extends StatelessWidget {
  const MediaInfoChips({
    super.key,
    this.typeLabel,
    this.sizeBytes,
    this.durationSeconds,
  });

  final String? typeLabel;
  final int? sizeBytes;
  final int? durationSeconds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = <String>[
      if (typeLabel != null && typeLabel!.trim().isNotEmpty) typeLabel!.trim(),
      if (durationSeconds != null && durationSeconds! > 0)
        mediaDurationLabel(durationSeconds!),
      if (sizeBytes != null && sizeBytes! > 0)
        offlineSizeLabel(l10n, sizeBytes!),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in chips)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentOnSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentOnSurface.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.softWhite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Infos média en ligne : type + durée/taille Vimeo et/ou taille audio distante.
class OnlineMediaInfoSection extends ConsumerWidget {
  const OnlineMediaInfoSection({
    super.key,
    this.videoId,
    this.audioUrl,
    this.hasVideo = false,
    this.hasAudio = false,
  });

  final String? videoId;
  final String? audioUrl;
  final bool hasVideo;
  final bool hasAudio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = videoId?.trim();
    final audio = audioUrl?.trim();

    final videoAsync =
        (id != null && id.isNotEmpty) ? ref.watch(videoDownloadsProvider(id)) : null;
    final audioSizeAsync = (audio != null && audio.startsWith('http'))
        ? ref.watch(remoteFileSizeProvider(audio))
        : null;

    final videoOptions = videoAsync?.valueOrNull;
    final videoLoading = videoAsync?.isLoading ?? false;
    final audioLoading = audioSizeAsync?.isLoading ?? false;
    int? durationSeconds;
    if (videoOptions != null) {
      for (final option in videoOptions) {
        final seconds = option.durationSeconds;
        if (seconds != null && seconds > 0) {
          durationSeconds = seconds;
          break;
        }
      }
    }
    final bestVideoSize = videoOptions == null || videoOptions.isEmpty
        ? null
        : videoOptions
            .map((e) => e.sizeBytes)
            .where((e) => e > 0)
            .fold<int>(0, (a, b) => a > b ? a : b);
    final audioSize = audioSizeAsync?.valueOrNull;

    final children = <Widget>[];

    if (hasVideo) {
      children.add(
        MediaInfoChips(
          typeLabel: l10n.video,
          durationSeconds: durationSeconds,
          sizeBytes: (bestVideoSize != null && bestVideoSize > 0)
              ? bestVideoSize
              : null,
        ),
      );
    }
    if (hasAudio) {
      children.add(
        MediaInfoChips(
          typeLabel: l10n.audio,
          sizeBytes: audioSize,
        ),
      );
    }

    if (children.isEmpty && !videoLoading && !audioLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mediaInfoTitle,
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.mediaInfoHint,
          style: TextStyle(color: AppTheme.grey, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        if (videoLoading || audioLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accentOnSurface,
              ),
            ),
          ),
        ...[
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            children[i],
          ],
        ],
        const SizedBox(height: 18),
      ],
    );
  }
}

/// Infos d'un fichier déjà téléchargé (hors ligne).
class OfflineMediaInfoSection extends StatelessWidget {
  const OfflineMediaInfoSection({super.key, required this.item});

  final OfflineMediaItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mediaInfoTitle,
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        MediaInfoChips(
          typeLabel: offlineFormatLabel(l10n, item.format),
          sizeBytes: item.fileSizeBytes,
          durationSeconds: item.durationSeconds,
        ),
      ],
    );
  }
}
