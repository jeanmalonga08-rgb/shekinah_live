import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../pages/notifications_page.dart';
import '../pages/user_manual_page.dart';
import '../providers/locale_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/theme_mode_provider.dart';

/// Barre d'actions Accueil : Notifications + menu (Mode · Langue).
class HomeHeaderToolbar extends ConsumerWidget {
  const HomeHeaderToolbar({
    super.key,
    required this.onNotifications,
  });

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final unread = ref.watch(notificationsUnreadCountProvider).valueOrNull ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.headerToolbarFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.headerToolbarBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.isLight
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToolbarAction(
                  tooltip: unread > 0
                      ? l10n.notificationUnread(unread)
                      : l10n.notificationsTitle,
                  onTap: onNotifications,
                  child: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread'),
                    backgroundColor: AppTheme.crossRed,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 21,
                      color: AppTheme.headerToolbarIcon.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                const _ToolbarDivider(),
                _ToolbarAction(
                  tooltip: l10n.homeMenuTitle,
                  onTap: () => _showQuickMenuSheet(context, ref),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 21,
                    color: AppTheme.brandAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickMenuSheet(BuildContext context, WidgetRef ref) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, _, _) => const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, _, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curved),
          child: Align(
            alignment: Alignment.topCenter,
            child: const _HomeQuickMenuPanel(),
          ),
        );
      },
    );
  }
}

class _HomeQuickMenuPanel extends ConsumerWidget {
  const _HomeQuickMenuPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          MediaQuery.paddingOf(context).top + 8,
          12,
          0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: AppTheme.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.muted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: AppTheme.onAccent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.homeMenuTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              Text(
                                l10n.homeMenuSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.grey,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppTheme.grey,
                          ),
                          tooltip: l10n.cancel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _MenuSection(
                          icon: Icons.palette_outlined,
                          title: l10n.settingsAppearance,
                          child: _ThemeModePicker(
                            value: themeMode,
                            onChanged: (mode) => ref
                                .read(themeModeProvider.notifier)
                                .setMode(mode),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MenuSection(
                          icon: Icons.translate_rounded,
                          title: l10n.settingsLanguage,
                          child: _LanguagePicker(
                            locale: locale,
                            onChanged: (option) => ref
                                .read(localeProvider.notifier)
                                .setLocale(option.locale),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const UserManualPage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderSubtle),
                                color: AppTheme.surfaceElevated
                                    .withValues(alpha: 0.55),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentOnSurface
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.help_outline_rounded,
                                      color: AppTheme.accentOnSurface,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.userManualTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.userManualSubtitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme.grey,
                                                height: 1.3,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.accentOnSurface,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.accentOnSurface),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentOnSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (ThemeMode.light, Icons.light_mode_rounded, l10n.themeModeLight),
      (ThemeMode.dark, Icons.dark_mode_rounded, l10n.themeModeDark),
      (ThemeMode.system, Icons.brightness_auto_rounded, l10n.themeModeSystem),
    ];

    return Row(
      children: options.map((option) {
        final selected = value == option.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: option.$1 != ThemeMode.system ? 8 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(option.$1),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accentOnSurface.withValues(alpha: 0.18)
                        : AppTheme.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppTheme.accentOnSurface.withValues(alpha: 0.65)
                          : AppTheme.borderSubtle,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        option.$2,
                        size: 20,
                        color: selected
                            ? AppTheme.accentOnSurface
                            : AppTheme.grey,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option.$3,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.2,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? AppTheme.white : AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.locale,
    required this.onChanged,
  });

  final Locale? locale;
  final ValueChanged<AppLocaleOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final rows = <List<AppLocaleOption>>[];
    for (var i = 0; i < kAppLocaleOptions.length; i += 3) {
      final end = (i + 3).clamp(0, kAppLocaleOptions.length);
      rows.add(kAppLocaleOptions.sublist(i, end));
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: 8),
          Row(
            children: List.generate(3, (columnIndex) {
              final option = columnIndex < rows[rowIndex].length
                  ? rows[rowIndex][columnIndex]
                  : null;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: columnIndex < 2 ? 8 : 0),
                  child: option == null
                      ? const SizedBox.shrink()
                      : _LanguageTile(
                          flag: option.flag,
                          label: localeOptionLabel(context.l10n, option.locale),
                          selected: locale?.languageCode ==
                              option.locale.languageCode,
                          onTap: () => onChanged(option),
                        ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accentOnSurface.withValues(alpha: 0.18)
                : AppTheme.background.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.accentOnSurface.withValues(alpha: 0.65)
                  : AppTheme.borderSubtle,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppTheme.white : AppTheme.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      color: AppTheme.headerToolbarBorder,
    );
  }
}
