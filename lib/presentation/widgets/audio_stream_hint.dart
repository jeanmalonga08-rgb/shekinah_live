import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../pages/live_page.dart';
import '../providers/audio_stream_hint_provider.dart';

/// Bannière Accueil : direct audio hors heures de culte (fermable, tap → Direct audio).
class AudioStreamHintBanner extends ConsumerWidget {
  const AudioStreamHintBanner({super.key});

  void _openAudioStream(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LivePage(startInAudioMode: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(audioStreamHintVisibleProvider);
    if (!visible) return const SizedBox.shrink();

    final l10n = context.l10n;
    final dismiss = ref.read(audioStreamHintDismissActionProvider);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _openAudioStream(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.accentOnSurface.withValues(alpha: 0.22),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  color: AppTheme.accentOnSurface,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.audioStreamOutsideCultTitle,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.audioStreamOutsideCultHint,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.close,
                onPressed: dismiss,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(
                  Icons.close_rounded,
                  color: AppTheme.grey,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
