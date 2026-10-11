import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class RequetePage extends StatelessWidget {
  const RequetePage({super.key});

  static List<_Announcement> _announcements(AppLocalizations l10n) => [
        _Announcement(
          title: l10n.requetesMoriah,
          dateLabel: l10n.notificationsInEffect,
          body: l10n.requetesMoriahBody,
        ),
        _Announcement(
          title: l10n.requetesSick,
          dateLabel: l10n.thisWeek,
          body: l10n.requetesSickBody,
        ),
        _Announcement(
          title: l10n.requetesYouth,
          dateLabel: l10n.notificationsPermanent,
          body: l10n.requetesYouthBody,
        ),
        _Announcement(
          title: l10n.requetesMission,
          dateLabel: l10n.notificationsPermanent,
          body: l10n.requetesMissionBody,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final announcements = _announcements(l10n);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.requetesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _HeaderBanner(
            icon: Icons.favorite_outline,
            accent: AppTheme.goldLight,
            title: l10n.requetesHeader,
            subtitle: l10n.requetesSubtitle(AppConstants.appName),
          ),
          const SizedBox(height: 16),
          ...announcements.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnnouncementCard(
                item: item,
                accent: AppTheme.accentGold,
                announcementLabel: l10n.homeOfficialAnnouncement.toUpperCase(),
                publishedByLabel: l10n.contactAssembly,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _FooterNote(text: l10n.requetesFooter),
        ],
      ),
    );
  }
}

class MariagePage extends StatelessWidget {
  const MariagePage({super.key});

  static List<_Announcement> _announcements(AppLocalizations l10n) => [
        _Announcement(
          title: l10n.mariageAnnounceProcedureTitle,
          dateLabel: l10n.mariageAnnounceProcedureDateLabel,
          body: l10n.mariageAnnounceProcedureBody,
        ),
        _Announcement(
          title: l10n.mariageAnnounceBansTitle,
          dateLabel: l10n.mariageAnnounceBansDateLabel,
          body: l10n.mariageAnnounceBansBody,
        ),
        _Announcement(
          title: l10n.mariageAnnouncePrepTitle,
          dateLabel: l10n.mariageAnnouncePrepDateLabel,
          body: l10n.mariageAnnouncePrepBody,
        ),
        _Announcement(
          title: l10n.mariageAnnounceMoriahTitle,
          dateLabel: l10n.mariageAnnounceMoriahDateLabel,
          body: l10n.mariageAnnounceMoriahBody,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final announcements = _announcements(l10n);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.ceremoniesWedding)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _HeaderBanner(
            icon: Icons.favorite,
            accent: const Color(0xFFE8A0BF),
            title: l10n.mariageRequestTitle,
            subtitle: l10n.mariageRequestInfo,
          ),
          const SizedBox(height: 16),
          ...announcements.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnnouncementCard(
                item: item,
                accent: const Color(0xFFE8A0BF),
                announcementLabel: l10n.homeOfficialAnnouncement.toUpperCase(),
                publishedByLabel: l10n.contactAssembly,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _FooterNote(text: l10n.mariageFooter),
        ],
      ),
    );
  }
}

class _Announcement {
  const _Announcement({
    required this.title,
    required this.dateLabel,
    required this.body,
  });

  final String title;
  final String dateLabel;
  final String body;
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: AppTheme.onDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(color: AppTheme.softWhite,
              height: 1.45,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.item,
    required this.accent,
    required this.announcementLabel,
    required this.publishedByLabel,
  });

  final _Announcement item;
  final Color accent;
  final String announcementLabel;
  final String publishedByLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  announcementLabel,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                item.dateLabel,
                style: TextStyle(color: AppTheme.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: TextStyle(color: AppTheme.onDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.body,
            style: TextStyle(color: AppTheme.softWhite,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.campaign_outlined, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                publishedByLabel,
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppTheme.muted,
        fontSize: 12,
        height: 1.4,
      ),
    );
  }
}
