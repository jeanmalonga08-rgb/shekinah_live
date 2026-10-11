import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/moriah_campaign_provider.dart';
import '../widgets/sht_widgets.dart';
import 'library_page.dart';
import 'login_page.dart';
import 'moriah_donation_page.dart';
import 'requete_mariage_pages.dart';

final appPackageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static String assemblyName(BuildContext context) =>
      context.l10n.profileAssemblyName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isLoggedIn = auth.isAuthenticated;
    final packageInfo = ref.watch(appPackageInfoProvider);
    final campaignActive =
        ref.watch(moriahCampaignActiveProvider).valueOrNull ?? false;

    final displayName = user?.displayName ?? l10n.profileVisitor;
    final email = user?.email ?? l10n.profileNotConnected;
    final phone = user?.phone ?? '—';
    final initials = user?.initials ?? 'V';
    final versionLabel = packageInfo.when(
      data: (info) => '${l10n.settingsVersion} ${info.version} (${info.buildNumber})',
      loading: () => '${l10n.settingsVersion}…',
      error: (_, _) => '${l10n.settingsVersion} ${AppConstants.appVersion}',
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 188,
            pinned: true,
            backgroundColor: AppTheme.background,
            foregroundColor: AppTheme.white,
            iconTheme: IconThemeData(color: AppTheme.white),
            title: Text(
              l10n.plusProfile,
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    BoxDecoration(gradient: AppTheme.headerGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentOnSurface,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentOnSurface.withValues(alpha: 0.25),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: AppTheme.surfaceElevated,
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: AppTheme.goldOnSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(color: AppTheme.softWhite,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _StatusChip(
                                label: isLoggedIn
                                    ? l10n.profileFaithfulAccount
                                    : l10n.profileVisitorMode,
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoggedIn) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: '12',
                            label: l10n.profilePredicationsListened,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            value: '3',
                            label: l10n.profileRequestsSent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            value: '8',
                            label: l10n.profileLivesJoined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      l10n.profileAccountInfo,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ShtCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _ProfileRow(
                            icon: Icons.badge_outlined,
                            label: l10n.authFullName,
                            value: displayName,
                          ),
                          Divider(height: 1, color: AppTheme.divider),
                          _ProfileRow(
                            icon: Icons.email_outlined,
                            label: l10n.contactEmail,
                            value: email,
                          ),
                          Divider(height: 1, color: AppTheme.divider),
                          _ProfileRow(
                            icon: Icons.phone_outlined,
                            label: l10n.profilePhone,
                            value: phone,
                          ),
                          Divider(height: 1, color: AppTheme.divider),
                          _ProfileRow(
                            icon: Icons.church_outlined,
                            label: l10n.profileAssembly,
                            value: assemblyName(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ] else ...[
                    ShtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profileLoginPrompt,
                            style: TextStyle(
                              color: AppTheme.softWhite,
                              height: 1.45,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.login_rounded),
                              label: Text(
                                l10n.authLogin,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                  Text(
                    l10n.profilePreferences,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.notifications_active_outlined,
                    title: l10n.notificationsTitle,
                    subtitle: l10n.profileNotificationsSubtitle,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.profilePreferencesSaved),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.favorite_outline,
                    title: l10n.profilePrayerTopics,
                    subtitle: l10n.profilePrayerTopicsSubtitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RequetePage()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (campaignActive) ...[
                    _ActionTile(
                      icon: Icons.volunteer_activism_outlined,
                      title: l10n.profileSupportMoriah,
                      subtitle: l10n.profileSupportMoriahSubtitle,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MoriahDonationPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  _ActionTile(
                    icon: Icons.menu_book_outlined,
                    title: l10n.libraryTitle,
                    subtitle: l10n.librarySubtitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LibraryPage()),
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.profileLoggedOut),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.crossRed,
                          side: BorderSide(
                            color: AppTheme.crossRed.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: Text(
                          l10n.profileLogout,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentOnSurface,
                          side: BorderSide(
                            color: AppTheme.accentOnSurface.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.login_rounded),
                        label: Text(
                          l10n.authLogin,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      versionLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentOnSurface.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentOnSurface.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.goldOnSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentOnSurface.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.goldOnSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.grey,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentOnSurface, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppTheme.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.royalBlue.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentOnSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppTheme.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.grey),
        ],
      ),
    );
  }
}
