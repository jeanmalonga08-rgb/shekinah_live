import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/app_update_info.dart';
import '../providers/app_update_provider.dart';

class AppUpdateBanner extends ConsumerWidget {
  const AppUpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promptAsync = ref.watch(appUpdatePromptProvider);

    return promptAsync.when(
      data: (prompt) {
        if (prompt == null) return const SizedBox.shrink();
        return _AppUpdateCard(prompt: prompt);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _AppUpdateCard extends ConsumerWidget {
  const _AppUpdateCard({required this.prompt});

  final AppUpdatePrompt prompt;

  Future<void> _openStore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dismiss = ref.read(appUpdateDismissProvider);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.accentOnSurface.withValues(alpha: 0.22),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOnSurface.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.system_update_alt_rounded,
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
                        prompt.required
                            ? l10n.homeUpdateRequired
                            : l10n.homeUpdateAvailable,
                        style: TextStyle(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeUpdateAvailableHint(
                          prompt.latestVersion.split('+').first,
                        ),
                        style: TextStyle(
                          color: AppTheme.grey,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      if (prompt.releaseNotes != null &&
                          prompt.releaseNotes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          prompt.releaseNotes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.softWhite,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!prompt.required) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => dismiss(prompt.latestVersion),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.softWhite,
                        side: BorderSide(
                          color: AppTheme.accentOnSurface.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(l10n.homeUpdateLater),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: prompt.required ? 1 : 2,
                  child: FilledButton(
                    onPressed: () => _openStore(prompt.storeUrl),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.ctaBackground,
                      foregroundColor: AppTheme.ctaForeground,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(l10n.homeUpdateNow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
