import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/sht_widgets.dart';

class EcamoPage extends StatelessWidget {
  const EcamoPage({super.key});

  static const _schoolGreen = Color(0xFF4CAF7A);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.ecamoTitle,
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: AppTheme.white,
        iconTheme: IconThemeData(color: AppTheme.white),
        actionsIconTheme: IconThemeData(color: AppTheme.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: l10n.website,
            onPressed: () => _openUrl(AppConstants.ecamoUrl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _HeaderBanner(),
          const SizedBox(height: 16),
          _HeroImage(
            assetPath: AppConstants.ecamoBannerAsset,
            label: '${l10n.ecamoLabel} — ${l10n.ecamoSubtitle}',
          ),
          const SizedBox(height: 16),
          _ScriptureQuote(),
          const SizedBox(height: 16),
          _SectionCard(
            title: l10n.ecamoSectionYouthChallenge,
            icon: Icons.warning_amber_rounded,
            iconColor: AppTheme.crossRed,
            paragraphs: [
              l10n.ecamoSectionYouthChallengeP1,
              l10n.ecamoSectionYouthChallengeP2,
              l10n.ecamoSectionYouthChallengeP3,
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.ecamoSectionInspiration,
            icon: Icons.auto_stories_outlined,
            iconColor: AppTheme.accentOnSurface,
            paragraphs: [
              l10n.ecamoSectionInspirationP1,
              l10n.ecamoSectionInspirationP2,
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.ecamoSectionSchool,
            icon: Icons.school_outlined,
            iconColor: _schoolGreen,
            paragraphs: [
              l10n.ecamoSectionSchoolP1,
              l10n.ecamoSectionSchoolP2,
              l10n.ecamoSectionSchoolP3,
            ],
          ),
          const SizedBox(height: 12),
          _KeyFactsCard(),
          const SizedBox(height: 12),
          _HeroImage(
            assetPath: AppConstants.fondationShekinahAsset,
            label: l10n.fondationLabel,
            height: 120,
          ),
          const SizedBox(height: 16),
          ShtCard(
            onTap: () => _openUrl(AppConstants.ecamoUrl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _schoolGreen.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.language, color: _schoolGreen),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.learnMore,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'shekinahgospel.org/ecamo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.white,
                            fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.grey),
              ],
            ),
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

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EcamoPage._schoolGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EcamoPage._schoolGreen.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  color: EcamoPage._schoolGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ecamoSubtitle,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${l10n.ecamoLabel} — ${l10n.ecamoSubtitle}',
                      style: TextStyle(
                        color: AppTheme.softWhite,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.ecamoHeaderSummary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.softWhite,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.assetPath,
    required this.label,
    this.height,
  });

  final String assetPath;
  final String label;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              assetPath,
              height: height ?? 180,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                height: height ?? 180,
                color: AppTheme.surfaceElevated,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.school_outlined,
                  color: EcamoPage._schoolGreen,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: AppTheme.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ScriptureQuote extends StatelessWidget {
  const _ScriptureQuote();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShtCard(
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            color: AppTheme.accentOnSurface.withValues(alpha: 0.7),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ecamoScriptureQuote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.ecamoScriptureRef,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentOnSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.paragraphs,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.white,
                      fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < paragraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Text(
              paragraphs[i],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeyFactsCard extends StatelessWidget {
  const _KeyFactsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.inBrief,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.white,
                fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _FactRow(
            icon: Icons.shield_outlined,
            text: l10n.ecamoFactSpiritualShelter,
          ),
          _FactRow(
            icon: Icons.menu_book_outlined,
            text: l10n.ecamoFactBiblePriority,
          ),
          _FactRow(
            icon: Icons.groups_outlined,
            text: l10n.ecamoFactEnrolled,
          ),
          _FactRow(
            icon: Icons.volunteer_activism_outlined,
            text: l10n.ecamoFactNonProfit,
          ),
          _FactRow(
            icon: Icons.flag_outlined,
            text: l10n.ecamoFactVision,
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: EcamoPage._schoolGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
