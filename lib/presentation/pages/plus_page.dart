import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/moriah_campaign_provider.dart';
import '../widgets/sht_widgets.dart';
import 'assembly_contact_page.dart';
import 'branham_predications_page.dart';
import 'contact_page.dart';
import 'ecamo_page.dart';
import 'documentaire_scenette_page.dart';
import 'fondation_shekinah_page.dart';
import 'moriah_donation_page.dart';
import 'recueils_cantiques_page.dart';
import 'shekinah_publication_page.dart';
import 'cultes_page.dart';
import 'notre_eglise_page.dart';
import 'notifications_page.dart';
import 'william_branham_page.dart';
import 'privacy_policy_page.dart';
import 'settings_page.dart';
import 'user_manual_page.dart';

class PlusPage extends ConsumerWidget {
  const PlusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final campaignActive =
        ref.watch(moriahCampaignActiveProvider).valueOrNull ?? false;
    final items = [
      _MenuItem(
        icon: Icons.event_outlined,
        label: l10n.plusCultes,
        color: AppTheme.accentOnSurface,
        onTap: () => _push(context, const CultesPage()),
      ),
      _MenuItem(
        label: l10n.plusNotreEglise,
        color: AppTheme.royalBlue,
        imageAsset: AppConstants.logoShekinahAsset,
        onTap: () => _push(context, const NotreEglisePage()),
      ),
      _MenuItem(
        label: l10n.plusPublication,
        color: AppTheme.royalBlue,
        imageAsset: AppConstants.shekinahPublicationsAsset,
        onTap: () => _push(context, const ShekinahPublicationPage()),
      ),
      _MenuItem(
        label: l10n.plusFondation,
        color: AppTheme.accentOnSurface,
        imageAsset: AppConstants.fondationShekinahAsset,
        onTap: () => _push(context, const FondationShekinahPage()),
      ),
      _MenuItem(
        label: l10n.plusEcamo,
        color: const Color(0xFF4CAF7A),
        imageAsset: AppConstants.ecamoBannerAsset,
        onTap: () => _push(context, const EcamoPage()),
      ),
      _MenuItem(
        label: l10n.plusBranham,
        color: AppTheme.royalBlue,
        imageAsset: AppConstants.broBranhamAsset,
        onTap: () => _push(context, const WilliamBranhamPage()),
      ),
      _MenuItem(
        icon: Icons.headphones_rounded,
        label: l10n.homeBranhamAudioTitle,
        color: AppTheme.accentOnSurface,
        onTap: () => _push(context, const BranhamPredicationsPage()),
      ),
      _MenuItem(
        icon: Icons.video_library_outlined,
        label: 'Documentaire - Scénette',
        color: AppTheme.accentOnSurface,
        onTap: () => _push(context, const DocumentaireScenettePage()),
      ),
      _MenuItem(
        icon: Icons.menu_book_outlined,
        label: 'Recueils de cantiques',
        color: AppTheme.royalBlue,
        onTap: () => _push(context, const RecueilsCantiquesPage()),
      ),
      if (campaignActive)
        _MenuItem(
          icon: Icons.volunteer_activism_outlined,
          label: l10n.plusDonations,
          color: AppTheme.goldOnSurface,
          onTap: () => _push(context, const MoriahDonationPage()),
        ),
      _MenuItem(
        icon: Icons.share_outlined,
        label: l10n.plusShareApp,
        color: AppTheme.royalBlue,
        onTap: () => _shareApp(context),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: l10n.plusNotifications,
        color: AppTheme.accentOnSurface,
        onTap: () => _push(context, const NotificationsPage()),
      ),
      _MenuItem(
        icon: Icons.contact_mail_outlined,
        label: l10n.plusContact,
        color: AppTheme.royalBlue,
        onTap: () => _push(context, const AssemblyContactPage()),
      ),
      _MenuItem(
        icon: Icons.help_outline_rounded,
        label: l10n.plusUserManual,
        color: AppTheme.accentOnSurface,
        onTap: () => _push(context, const UserManualPage()),
      ),
      _MenuItem(
        icon: Icons.info_outline,
        label: l10n.plusAbout,
        color: AppTheme.accentOnSurface,
        onTap: () => _push(context, const ContactPage()),
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        label: l10n.plusPrivacy,
        color: AppTheme.grey,
        onTap: () => _push(context, const PrivacyPolicyPage()),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        label: l10n.plusSettings,
        color: AppTheme.grey,
        onTap: () => _push(context, const SettingsPage()),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const AppLogo(size: 64, showShadow: false),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.plusTitle,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.headerOnSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              AppConstants.templeMoriahName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.headerOnSurfaceMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              l10n.churchTagline,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.headerOnSurfaceSubtle,
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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((_, i) {
                final item = items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ShtCard(
                    onTap: item.onTap,
                    child: Row(
                      children: [
                        item.buildLeading(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.label,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppTheme.white),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppTheme.accentOnSurface,
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: items.length),
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _shareApp(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    await SharePlus.instance.share(
      ShareParams(
        text: context.l10n.shareAppMessage(
          AppConstants.appName,
          AppConstants.playStoreUrl,
          AppConstants.websiteUrl,
        ),
        subject: AppConstants.appName,
        sharePositionOrigin: origin,
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    this.icon,
    this.imageAsset,
    required this.label,
    required this.color,
    required this.onTap,
  }) : assert(icon != null || imageAsset != null);

  final IconData? icon;
  final String? imageAsset;
  final String label;
  final Color color;
  final VoidCallback onTap;

  Widget buildLeading() {
    if (imageAsset != null) {
      return ClipOval(
        child: SizedBox(
          width: 48,
          height: 48,
          child: Image.asset(imageAsset!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}
