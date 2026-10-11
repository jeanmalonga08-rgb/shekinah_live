import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/sht_widgets.dart';

class WilliamBranhamPage extends StatelessWidget {
  const WilliamBranhamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.branhamTitle,
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
            onPressed: () => _openUrl(AppConstants.williamBranhamUrl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const _HeaderBanner(),
          const SizedBox(height: 16),
          _HeroImage(
            assetPath: AppConstants.broBranhamAsset,
            label: l10n.branhamTitle,
          ),
          const SizedBox(height: 16),
          _ScriptureQuote(
            quote: l10n.branhamScriptureHoseaQuote,
            reference: l10n.branhamScriptureHoseaRef,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: l10n.branhamSectionIntro,
            icon: Icons.auto_awesome_outlined,
            iconColor: AppTheme.accentOnSurface,
            paragraphs: [l10n.branhamIntroP1],
          ),
          const SizedBox(height: 12),
          _ScriptureQuote(
            quote: l10n.branhamScriptureMalachiQuote,
            reference: l10n.branhamScriptureMalachiRef,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.branhamSectionDoctrine,
            icon: Icons.menu_book_outlined,
            iconColor: AppTheme.accentOnSurface,
            paragraphs: [l10n.branhamDoctrineP1],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.branhamSectionBeginning,
            icon: Icons.child_care_outlined,
            iconColor: AppTheme.royalBlue,
            paragraphs: [
              l10n.branhamBeginningQuote,
              l10n.branhamBeginningP1,
              l10n.branhamBeginningP2,
              l10n.branhamBeginningP3,
              l10n.branhamBeginningP4,
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.branhamSectionVisions,
            icon: Icons.visibility_outlined,
            iconColor: AppTheme.crossRed,
            paragraphs: [
              l10n.branhamVisionsP1,
              l10n.branhamVisionsP2,
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.branhamSectionYouth,
            icon: Icons.landscape_outlined,
            iconColor: AppTheme.accentOnSurface,
            paragraphs: [
              l10n.branhamYouthIntro,
              l10n.branhamYouthQuote,
            ],
          ),
          const SizedBox(height: 12),
          _QuoteCard(
            quote: l10n.branhamBaptistQuote,
            caption: l10n.branhamBaptistCaption,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.branhamSectionAngelVisit,
            icon: Icons.verified_user_outlined,
            iconColor: AppTheme.royalBlue,
            paragraphs: [
              l10n.branhamAngelVisitP1,
              l10n.branhamAngelVisitP2,
              l10n.branhamHealingRevivalP1,
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.branhamSectionPillarOfFire,
            icon: Icons.local_fire_department_outlined,
            iconColor: AppTheme.crossRed,
            paragraphs: [
              l10n.branhamPillarP1,
              l10n.branhamPillarP2,
              l10n.branhamPillarP3,
              l10n.branhamPillarP4,
              l10n.branhamHoustonQuote,
              l10n.branhamPillarP5,
              l10n.branhamPillarWitnessQuote,
              l10n.branhamPillarP6,
            ],
          ),
          const SizedBox(height: 12),
          const _KeyFactsCard(),
          const SizedBox(height: 12),
          _ScriptureQuote(
            quote: l10n.branhamClosingQuote,
            reference: l10n.branhamClosingRef,
          ),
          const SizedBox(height: 16),
          ShtCard(
            onTap: () => _openUrl(AppConstants.williamBranhamUrl),
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
                        'shekinahgospel.org/william-branham',
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
          color: AppTheme.accentOnSurface.withValues(alpha: 0.4),
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
                  Icons.record_voice_over,
                  color: AppTheme.accentOnSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.branhamTitle,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.branhamSubtitle,
                      style: TextStyle(
                        color: AppTheme.softWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.branhamHeaderSummary,
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
  const _HeroImage({required this.assetPath, required this.label});

  final String assetPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColoredBox(
                color: AppTheme.surfaceElevated,
                child: Image.asset(
                  assetPath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      Icons.person_outline,
                      color: AppTheme.accentOnSurface,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ScriptureQuote extends StatelessWidget {
  const _ScriptureQuote({required this.quote, required this.reference});

  final String quote;
  final String reference;

  @override
  Widget build(BuildContext context) {
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
            quote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            reference,
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

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.caption});

  final String quote;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      child: Column(
        children: [
          Text(
            quote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: AppTheme.white,
                fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.grey,
                  fontWeight: FontWeight.w600,
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
                    fontStyle: i == 0 && paragraphs[i].startsWith('«')
                        ? FontStyle.italic
                        : null,
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
          _FactRow(icon: Icons.cake_outlined, text: l10n.branhamFactBirth),
          _FactRow(icon: Icons.bolt_outlined, text: l10n.branhamFactMalachi),
          _FactRow(icon: Icons.healing_outlined, text: l10n.branhamFactMinistry),
          _FactRow(icon: Icons.photo_camera_outlined, text: l10n.branhamFactPhoto),
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
