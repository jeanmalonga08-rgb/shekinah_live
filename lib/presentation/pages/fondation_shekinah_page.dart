import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/sht_widgets.dart';

class FondationShekinahPage extends StatelessWidget {
  const FondationShekinahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.fondationTitle,
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
            onPressed: () => _openUrl(AppConstants.fondationShekinahUrl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const _HeaderBanner(),
          const SizedBox(height: 16),
          _HeroImage(
            assetPath: AppConstants.fondationShekinahAsset,
            label: l10n.fondationLabel,
          ),
          const SizedBox(height: 16),
          const _ScriptureQuote(),
          const SizedBox(height: 16),
          _SectionCard(
            title: l10n.fondationWordForAll,
            icon: Icons.menu_book_outlined,
            iconColor: AppTheme.accentOnSurface,
            paragraphs: [
              l10n.fondationWordForAllP1,
              l10n.fondationWordForAllP2,
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.fondationWrittenWord,
            icon: Icons.history_edu_outlined,
            iconColor: AppTheme.royalBlue,
            paragraphs: [
              l10n.fondationWrittenWordP1,
              l10n.fondationWrittenWordP2,
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.fondationMessageNations,
            icon: Icons.public_outlined,
            iconColor: AppTheme.crossRed,
            paragraphs: [
              l10n.fondationMessageNationsP1,
              l10n.fondationMessageNationsP2,
            ],
          ),
          const SizedBox(height: 12),
          const _KeyFactsCard(),
          const SizedBox(height: 16),
          _HeroImage(
            assetPath: AppConstants.logoAsset,
            label: AppConstants.appName,
            height: 72,
          ),
          const SizedBox(height: 16),
          ShtCard(
            onTap: () => _openUrl(AppConstants.fondationShekinahUrl),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.language, color: AppTheme.accentOnSurface),
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
                        'shekinahgospel.org/assemblee',
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
          color: AppTheme.accentOnSurface.withValues(alpha: 0.35),
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
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_outlined,
                  color: AppTheme.accentOnSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.fondationTitle,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      l10n.churchTagline,
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
            l10n.visionMessage,
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
                child: Icon(
                  Icons.account_balance_outlined,
                  color: AppTheme.accentOnSurface,
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
            l10n.fondationScriptureQuote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.fondationScriptureRef,
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
            icon: Icons.church_outlined,
            text: l10n.fondationFactAssembly,
          ),
          _FactRow(
            icon: Icons.person_outline,
            text: l10n.pastorTitle,
          ),
          _FactRow(
            icon: Icons.location_on_outlined,
            text: l10n.assemblyAddress,
          ),
          _FactRow(
            icon: Icons.volunteer_activism_outlined,
            text: l10n.fondationFactMissionWorks,
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
          Icon(icon, color: AppTheme.accentOnSurface, size: 20),
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
