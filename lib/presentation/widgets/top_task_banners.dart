import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_conversion_manager_provider.dart';
import '../providers/offline_download_progress_provider.dart';
import 'audio_conversion_banner.dart';
import 'offline_download_banner.dart';

/// Colonne des bannières non bloquantes (téléchargements + conversions).
class TopTaskBanners extends ConsumerWidget {
  const TopTaskBanners({super.key, this.topInset = 8});

  final double topInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadVisible =
        ref.watch(offlineDownloadManagerProvider.select((s) => s.isVisible));
    final conversionVisible =
        ref.watch(audioConversionManagerProvider.select((s) => s.isVisible));
    if (!downloadVisible && !conversionVisible) {
      return const SizedBox.shrink();
    }

    final top = MediaQuery.paddingOf(context).top + topInset;
    return Positioned(
      left: 12,
      right: 12,
      top: top,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OfflineDownloadBanner(embedded: true),
          if (downloadVisible && conversionVisible) const SizedBox(height: 8),
          const AudioConversionBanner(embedded: true),
        ],
      ),
    );
  }
}
