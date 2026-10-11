import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/contact_launcher.dart';
import '../widgets/sht_widgets.dart';
import '../widgets/whatsapp_icon.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.aboutAppPageTitle,
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: AppTheme.white,
        iconTheme: IconThemeData(color: AppTheme.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            const AppLogo(size: 112),
            const SizedBox(height: 14),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              l10n.churchTagline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentOnSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeScriptureBanner,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            _ExpandableAboutContent(
              sections: [
                _AboutSection(
                  title: l10n.aboutWhyTitle,
                  paragraphs: [
                    l10n.aboutWhyDeveloper,
                    l10n.aboutWhyIntro,
                    l10n.aboutWhyP1,
                    l10n.aboutWhyP2,
                    l10n.aboutWhyP3,
                    l10n.aboutWhyP4,
                  ],
                ),
                _AboutSection(
                  title: l10n.aboutChurchFocusedTitle,
                  paragraphs: [
                    l10n.aboutChurchFocusedP1,
                    l10n.aboutChurchFocusedP2,
                    l10n.aboutChurchFocusedP3,
                  ],
                ),
                _AboutSection(
                  title: l10n.aboutLibraryTitle,
                  paragraphs: [
                    l10n.aboutLibraryP1,
                    l10n.aboutLibraryP2,
                    l10n.aboutLibraryP3,
                  ],
                ),
                _AboutSection(
                  title: l10n.aboutContinuityTitle,
                  paragraphs: [
                    l10n.aboutContinuityP1,
                    l10n.aboutContinuityP2,
                    l10n.aboutContinuityP3,
                  ],
                ),
                _AboutSection(
                  title: l10n.aboutDeveloperServiceTitle,
                  paragraphs: [
                    l10n.aboutDeveloperServiceP1,
                    l10n.aboutDeveloperServiceP2,
                    l10n.aboutDeveloperServiceP3,
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ShtCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.email, color: AppTheme.accentOnSurface),
                    title: Text(l10n.contactEmail),
                    subtitle: Text(AppConstants.developerEmail),
                    onTap: () =>
                        ContactLauncher.openEmail(AppConstants.developerEmail),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.phone_outlined, color: AppTheme.accentOnSurface),
                    title: Text(l10n.contactPhone),
                    subtitle: Text(AppConstants.developerPhoneDisplay),
                    onTap: () => ContactLauncher.openPhone(
                      AppConstants.developerPhoneE164,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const WhatsAppIcon(size: 28),
                    title: Text(l10n.contactWhatsApp),
                    subtitle: Text(AppConstants.developerPhoneDisplay),
                    trailing: Icon(
                      Icons.open_in_new,
                      color: AppTheme.grey,
                      size: 18,
                    ),
                    onTap: () => ContactLauncher.openWhatsApp(
                      AppConstants.developerWhatsAppPhone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.contactCopyright(AppConstants.appVersion),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection {
  const _AboutSection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;
}

class _ExpandableAboutContent extends StatefulWidget {
  const _ExpandableAboutContent({required this.sections});

  static const int previewMaxLength = 300;

  final List<_AboutSection> sections;

  @override
  State<_ExpandableAboutContent> createState() =>
      _ExpandableAboutContentState();
}

class _ExpandableAboutContentState extends State<_ExpandableAboutContent> {
  bool _expanded = false;

  String get _fullText {
    final buffer = StringBuffer();
    for (var i = 0; i < widget.sections.length; i++) {
      final section = widget.sections[i];
      if (i > 0) buffer.writeln();
      buffer.writeln(section.title);
      for (final paragraph in section.paragraphs) {
        buffer.writeln();
        buffer.writeln(paragraph);
      }
    }
    return buffer.toString().trim();
  }

  bool get _needsTruncate =>
      _fullText.length > _ExpandableAboutContent.previewMaxLength;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!_needsTruncate || _expanded) {
      return Column(
        children: [
          for (var i = 0; i < widget.sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _AboutSectionCard(section: widget.sections[i]),
          ],
          if (_needsTruncate) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _expanded = false),
                child: Text(l10n.seeLess),
              ),
            ),
          ],
        ],
      );
    }

    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.5,
        );

    return ShtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _truncateText(
              _fullText,
              _ExpandableAboutContent.previewMaxLength,
            ),
            style: bodyStyle,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _expanded = true),
              child: Text(l10n.seeMoreArrow),
            ),
          ),
        ],
      ),
    );
  }

  static String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    var cut = text.substring(0, maxLength);
    final lastSpace = cut.lastIndexOf(' ');
    if (lastSpace > maxLength * 0.8) {
      cut = cut.substring(0, lastSpace);
    }
    return '$cut…';
  }
}

class _AboutSectionCard extends StatelessWidget {
  const _AboutSectionCard({required this.section});

  final _AboutSection section;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.5,
        );

    return ShtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.accentOnSurface,
                ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < section.paragraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Text(section.paragraphs[i], style: bodyStyle),
          ],
        ],
      ),
    );
  }
}
