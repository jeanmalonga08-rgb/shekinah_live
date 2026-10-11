import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../../core/utils/contact_launcher.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../widgets/whatsapp_icon.dart';
import 'privacy_policy_page.dart';
import 'profile_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final packageInfo = ref.watch(appPackageInfoProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final versionLabel = packageInfo.when(
      data: (info) => '${info.version} (${info.buildNumber})',
      loading: () => '…',
      error: (_, _) => AppConstants.appVersion,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: l10n.settingsAppearance),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  l10n.settingsTheme,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _ThemeChoiceChip(
                        label: l10n.settingsThemeLight,
                        icon: Icons.light_mode_outlined,
                        selected: themeMode == ThemeMode.light,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ThemeChoiceChip(
                        label: l10n.settingsThemeDark,
                        icon: Icons.dark_mode_outlined,
                        selected: themeMode == ThemeMode.dark,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.dark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ThemeChoiceChip(
                        label: l10n.settingsThemeSystem,
                        icon: Icons.brightness_auto_outlined,
                        selected: themeMode == ThemeMode.system,
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .setMode(ThemeMode.system),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  l10n.settingsLanguage,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...kAppLocaleOptions.map((option) {
                final selected =
                    locale?.languageCode == option.locale.languageCode;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => ref
                        .read(localeProvider.notifier)
                        .setLocale(option.locale),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            option.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              labelForLocale(l10n, option.locale),
                              style: TextStyle(
                                color: selected
                                    ? AppTheme.white
                                    : AppTheme.grey,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.accentOnSurface,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeader(title: l10n.settingsApplication),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.settingsVersion,
                subtitle: versionLabel,
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.language,
                title: l10n.website,
                subtitle: AppConstants.websiteUrl,
                onTap: () => _openUrl(AppConstants.websiteUrl),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeader(title: l10n.settingsWorshipSchedule),
          _SettingsCard(
            children: [
              ...worshipScheduleEntries(l10n).map(
                (entry) => _SettingsTile(
                  icon: Icons.schedule,
                  title: entry.day,
                  subtitle: entry.time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeader(title: l10n.settingsInformation),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingsPrivacyPolicy,
                subtitle: l10n.settingsPrivacySubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.email_outlined,
                title: l10n.settingsDeveloperContact,
                subtitle: AppConstants.developerEmail,
                onTap: () => ContactLauncher.openEmail(AppConstants.developerEmail),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.phone_outlined,
                title: l10n.contactPhone,
                subtitle: AppConstants.developerPhoneDisplay,
                onTap: () => ContactLauncher.openPhone(
                  AppConstants.developerPhoneE164,
                ),
              ),
              const Divider(height: 1),
              _SettingsTile(
                leading: const WhatsAppIcon(size: 22),
                title: l10n.contactWhatsApp,
                subtitle: AppConstants.developerPhoneDisplay,
                onTap: () => ContactLauncher.openWhatsApp(
                  AppConstants.developerWhatsAppPhone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ThemeChoiceChip extends StatelessWidget {
  const _ThemeChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.accentOnSurface.withValues(alpha: 0.18)
          : AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.accentOnSurface.withValues(alpha: 0.7)
                  : AppTheme.muted.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppTheme.accentOnSurface : AppTheme.grey,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.white : AppTheme.grey,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.accentOnSurface,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentOnSurface.withValues(alpha: 0.14)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.icon,
    this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : assert(icon != null || leading != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ??
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.royalBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accentOnSurface, size: 20),
          ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.grey, fontSize: 12.5),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: AppTheme.grey)
          : null,
      onTap: onTap,
    );
  }
}
