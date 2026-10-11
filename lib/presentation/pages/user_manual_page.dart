import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Manuel d'utilisation de l'application.
class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = [
      _ManualSection(
        icon: Icons.handshake_outlined,
        title: l10n.userManualIntroTitle,
        body: l10n.userManualIntroBody,
      ),
      _ManualSection(
        icon: Icons.view_agenda_outlined,
        title: l10n.userManualNavTitle,
        body: l10n.userManualNavBody,
      ),
      _ManualSection(
        icon: Icons.home_outlined,
        title: l10n.userManualHomeTitle,
        body: l10n.userManualHomeBody,
      ),
      _ManualSection(
        icon: Icons.live_tv_outlined,
        title: l10n.userManualLiveTitle,
        body: l10n.userManualLiveBody,
      ),
      _ManualSection(
        icon: Icons.mic_none_rounded,
        title: l10n.userManualPredicationsTitle,
        body: l10n.userManualPredicationsBody,
      ),
      _ManualSection(
        icon: Icons.music_note_outlined,
        title: l10n.userManualCantiquesTitle,
        body: l10n.userManualCantiquesBody,
      ),
      _ManualSection(
        icon: Icons.download_for_offline_outlined,
        title: l10n.userManualOfflineTitle,
        body: l10n.userManualOfflineBody,
      ),
      _ManualSection(
        icon: Icons.menu_book_outlined,
        title: l10n.userManualLibraryTitle,
        body: l10n.userManualLibraryBody,
      ),
      _ManualSection(
        icon: Icons.search_rounded,
        title: l10n.userManualSearchTitle,
        body: l10n.userManualSearchBody,
      ),
      _ManualSection(
        icon: Icons.notifications_outlined,
        title: l10n.userManualNotificationsTitle,
        body: l10n.userManualNotificationsBody,
      ),
      _ManualSection(
        icon: Icons.apps_outlined,
        title: l10n.userManualPlusTitle,
        body: l10n.userManualPlusBody,
      ),
      _ManualSection(
        icon: Icons.tips_and_updates_outlined,
        title: l10n.userManualTipsTitle,
        body: l10n.userManualTipsBody,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.userManualTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOnSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: AppTheme.accentOnSurface,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.userManualTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.userManualSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.grey,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${AppConstants.appName} · v${AppConstants.appVersion}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.accentOnSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < sections.length; i++) ...[
            _ManualExpansionTile(
              section: sections[i],
              initiallyExpanded: i == 0,
            ),
            if (i < sections.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ManualSection {
  const _ManualSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _ManualExpansionTile extends StatelessWidget {
  const _ManualExpansionTile({
    required this.section,
    this.initiallyExpanded = false,
  });

  final _ManualSection section;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.borderSubtle),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.borderSubtle),
          ),
          leading: Icon(section.icon, color: AppTheme.accentOnSurface),
          title: Text(
            section.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _ManualBody(text: section.body),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualBody extends StatelessWidget {
  const _ManualBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.grey,
          height: 1.45,
        );
    final headingStyle = bodyStyle?.copyWith(
      color: AppTheme.softWhite,
      fontWeight: FontWeight.w700,
    );

    final blocks = text.split('\n\n');
    return SelectableText.rich(
      TextSpan(
        children: [
          for (var i = 0; i < blocks.length; i++) ...[
            if (i > 0) const TextSpan(text: '\n\n'),
            ..._blockSpans(blocks[i], bodyStyle, headingStyle),
          ],
        ],
      ),
    );
  }

  List<TextSpan> _blockSpans(
    String block,
    TextStyle? bodyStyle,
    TextStyle? headingStyle,
  ) {
    final lines = block.split('\n');
    final spans = <TextSpan>[];

    for (var i = 0; i < lines.length; i++) {
      if (i > 0) spans.add(const TextSpan(text: '\n'));

      final line = lines[i];
      if (line.startsWith('• ')) {
        spans.add(TextSpan(text: line, style: bodyStyle));
        continue;
      }

      final nextIsBullet =
          i + 1 < lines.length && lines[i + 1].startsWith('• ');
      if (nextIsBullet && line.isNotEmpty) {
        spans.add(TextSpan(text: line, style: headingStyle));
      } else {
        spans.add(TextSpan(text: line, style: bodyStyle));
      }
    }

    return spans;
  }
}
