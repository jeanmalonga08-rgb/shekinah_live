import 'package:flutter/material.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Bannière « déjà disponible hors ligne » sur les fiches détail.
class OfflineAvailableBanner extends StatelessWidget {
  const OfflineAvailableBanner({
    super.key,
    required this.hasOfflineAudio,
    required this.hasOfflineVideo,
  });

  final bool hasOfflineAudio;
  final bool hasOfflineVideo;

  @override
  Widget build(BuildContext context) {
    if (!hasOfflineAudio && !hasOfflineVideo) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final message = hasOfflineAudio && hasOfflineVideo
        ? l10n.offlineAvailableBannerBoth
        : hasOfflineAudio
            ? l10n.offlineAvailableBannerAudio
            : l10n.offlineAvailableBannerVideo;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.offline_pin, color: AppTheme.accentOnSurface, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.goldOnSurface,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
