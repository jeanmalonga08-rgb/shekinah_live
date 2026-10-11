import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/sister_churches_data.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/sister_church_card.dart';
import '../widgets/sht_widgets.dart';

enum NotreEgliseSection { about, pastor, sisterChurches }

extension NotreEgliseSectionX on NotreEgliseSection {
  String label(AppLocalizations l10n) {
    switch (this) {
      case NotreEgliseSection.about:
        return l10n.notreEgliseAbout;
      case NotreEgliseSection.pastor:
        return l10n.notreEglisePastor;
      case NotreEgliseSection.sisterChurches:
        return l10n.notreEgliseSisterChurches;
    }
  }

  static NotreEgliseSection? fromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final normalized =
        url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    if (normalized == AppConstants.assemblyPastorUrl) {
      return NotreEgliseSection.pastor;
    }
    if (normalized == AppConstants.assemblySisterChurchesUrl) {
      return NotreEgliseSection.sisterChurches;
    }
    if (normalized == AppConstants.assemblyUrl) {
      return NotreEgliseSection.about;
    }
    return null;
  }
}

class NotreEglisePage extends StatefulWidget {
  const NotreEglisePage({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  State<NotreEglisePage> createState() => _NotreEglisePageState();
}

class _NotreEglisePageState extends State<NotreEglisePage> {
  late NotreEgliseSection _section;

  @override
  void initState() {
    super.initState();
    _section = NotreEgliseSectionX.fromUrl(widget.initialUrl) ??
        NotreEgliseSection.about;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.notreEgliseTitle,
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
            onPressed: () => _openUrl(AppConstants.assemblyUrl),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < NotreEgliseSection.values.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 34,
                        color: AppTheme.borderSubtle,
                      ),
                    Expanded(
                      child: _NotreEgliseMenuItem(
                        label: NotreEgliseSection.values[i].label(l10n),
                        selected: _section == NotreEgliseSection.values[i],
                        onTap: () => setState(
                          () => _section = NotreEgliseSection.values[i],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _section.index,
        children: const [
          _AboutTab(),
          _PastorTab(),
          _SisterChurchesTab(),
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

class _NotreEgliseMenuItem extends StatelessWidget {
  const _NotreEgliseMenuItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.accentOnSurface.withValues(alpha: 0.18)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppTheme.accentOnSurface : AppTheme.grey,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const _AboutHeaderBanner(),
        const SizedBox(height: 16),
        _HeroImage(
          assetPath: AppConstants.logoShekinahAsset,
          label: AppConstants.appName,
        ),
        const SizedBox(height: 16),
        _ScriptureQuote(
          quote: l10n.fondationScriptureQuote,
          reference: l10n.fondationScriptureRef,
        ),
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
        _KeyFactsCard(),
        const SizedBox(height: 12),
        ShtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: AppTheme.accentOnSurface, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.contactAddress,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.white,
                        fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final line in assemblyAddressLines(l10n)) ...[
                Text(
                  line,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(AppConstants.assemblyMapLaunchUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(l10n.contactMap),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PastorTab extends StatelessWidget {
  const _PastorTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _HeroImage(
          assetPath: AppConstants.pastorAsset,
          label: l10n.pastorTitle,
          square: true,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        ShtCard(
          child: Row(
            children: [
              _PastorAvatar(size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pastorTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.notreEglisePastor,
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
        const SizedBox(height: 16),
        _SectionCard(
          title: l10n.notreEglisePastor,
          icon: Icons.volunteer_activism_outlined,
          iconColor: AppTheme.accentOnSurface,
          paragraphs: [l10n.notreEglisePastorGreeting],
        ),
        const SizedBox(height: 12),
        _ScriptureQuote(
          quote: l10n.ecamoScriptureQuote,
          reference: l10n.ecamoScriptureRef,
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l10n.notreEglisePastorMessage,
          icon: Icons.auto_stories_outlined,
          iconColor: AppTheme.royalBlue,
          paragraphs: [
            l10n.notreEglisePastorP1,
            l10n.notreEglisePastorP2,
            l10n.notreEglisePastorP3,
            l10n.notreEglisePastorP4,
            l10n.notreEglisePastorP5,
          ],
        ),
        const SizedBox(height: 12),
        ShtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.notreEglisePastorSignature,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.grey,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pastorTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.white,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PastorAvatar extends StatelessWidget {
  const _PastorAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accentOnSurface.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentOnSurface.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppConstants.pastorAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => DecoratedBox(
            decoration: BoxDecoration(gradient: AppTheme.goldGradient),
            child: Center(
              child: Text(
                'RD',
                style: TextStyle(
                  color: AppTheme.onAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SisterChurchesTab extends StatelessWidget {
  const _SisterChurchesTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
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
                      color: AppTheme.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.church, color: AppTheme.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.notreEgliseSisterChurches,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.notreEgliseSisterChurchesSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.softWhite,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.notreEgliseSisterChurchesCount(sisterChurches.length),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.accentOnSurface.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < sisterChurches.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          SisterChurchCard(church: sisterChurches[i]),
        ],
      ],
    );
  }
}

class _AboutHeaderBanner extends StatelessWidget {
  const _AboutHeaderBanner();

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
              ClipOval(
                child: Image.asset(
                  AppConstants.logoShekinahAsset,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 52,
                    height: 52,
                    color: AppTheme.white.withValues(alpha: 0.15),
                    child: Icon(Icons.church, color: AppTheme.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.churchTagline,
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
            l10n.notreEgliseHeaderSummary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.softWhite,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeScriptureBanner,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
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
    this.fit = BoxFit.contain,
    this.square = false,
  }) : height = 160;

  final String assetPath;
  final String label;
  final double height;
  final BoxFit fit;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: square
                ? AspectRatio(
                    aspectRatio: 1,
                    child: ColoredBox(
                      color: AppTheme.surfaceElevated,
                      child: Image.asset(
                        assetPath,
                        width: double.infinity,
                        height: double.infinity,
                        fit: fit,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(
                            Icons.person_outline,
                            color: AppTheme.accentOnSurface,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    assetPath,
                    height: height,
                    width: double.infinity,
                    fit: fit,
                    errorBuilder: (_, _, _) => Container(
                      height: height,
                      color: AppTheme.surfaceElevated,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.church_outlined,
                        color: AppTheme.accentOnSurface,
                        size: 48,
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
            icon: Icons.volunteer_activism_outlined,
            text: l10n.fondationFactMissionWorks,
          ),
          _FactRow(
            icon: Icons.location_on_outlined,
            text: l10n.assemblyAddress,
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
