import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/sht_widgets.dart';

class AssemblyContactPage extends StatelessWidget {
  const AssemblyContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.contactTitle,
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: AppTheme.white,
        iconTheme: IconThemeData(color: AppTheme.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const AppLogo(size: 96),
          const SizedBox(height: 12),
          Text(
            AppConstants.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            l10n.churchTagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentOnSurface,
                ),
          ),
          const SizedBox(height: 24),
          _ContactCard(
            icon: Icons.mail_outlined,
            label: l10n.contactEmail.toUpperCase(),
            onTap: () => _openEmail(),
            child: Text(
              AppConstants.assemblyEmail,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accentOnSurface,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.location_on_outlined,
            label: l10n.contactAddress.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in assemblyAddressLines(l10n)) ...[
                  Text(
                    line,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.language,
            label: l10n.website.toUpperCase(),
            onTap: () => _openUrl(AppConstants.websiteUrl),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppConstants.websiteUrl.replaceFirst('https://', ''),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accentOnSurface,
                        ),
                  ),
                ),
                Icon(Icons.open_in_new, color: AppTheme.grey, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _AssemblyMapCard(),
        ],
      ),
    );
  }

  static Future<void> openMaps() async {
    final uri = Uri.parse(AppConstants.assemblyMapLaunchUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.assemblyEmail,
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _AssemblyMapCard extends StatefulWidget {
  const _AssemblyMapCard();

  @override
  State<_AssemblyMapCard> createState() => _AssemblyMapCardState();
}

class _AssemblyMapCardState extends State<_AssemblyMapCard> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) async {
            await _hideMapOverlays();
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      // OSM embed works in WebView; Google Embed API requires a real iframe
      // and often blocks direct WebView loads with an API error page.
      ..loadRequest(Uri.parse(AppConstants.assemblyMapEmbedUrl));
  }

  Future<void> _hideMapOverlays() async {
    try {
      await _controller.runJavaScript('''
(function () {
  var css = document.createElement('style');
  css.textContent = `
    .leaflet-control-container,
    .leaflet-control,
    .leaflet-control-attribution,
    .leaflet-bottom,
    .leaflet-top,
    .leaflet-pane.leaflet-overlay-pane > *:not(.leaflet-marker-icon):not(.leaflet-marker-shadow),
    #export-link,
    .map-legend,
    .soft-button,
    a, button {
      display: none !important;
      visibility: hidden !important;
      opacity: 0 !important;
      pointer-events: none !important;
    }
    .leaflet-marker-icon,
    .leaflet-marker-shadow {
      display: block !important;
      visibility: visible !important;
      opacity: 1 !important;
    }
  `;
  document.head.appendChild(css);

  function scrub() {
    document.querySelectorAll(
      '.leaflet-control-container, .leaflet-control, .leaflet-control-attribution, .leaflet-bottom, .leaflet-top, a, button'
    ).forEach(function (el) {
      if (el.classList && (el.classList.contains('leaflet-marker-icon') || el.classList.contains('leaflet-marker-shadow'))) {
        return;
      }
      el.remove();
    });
  }
  scrub();
  setTimeout(scrub, 300);
  setTimeout(scrub, 1000);
})();
''');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShtCard(
      onTap: AssemblyContactPage.openMaps,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.map_outlined, color: AppTheme.accentOnSurface),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.contactAddress.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.grey,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.assemblyAddress,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    ColoredBox(
                      color: AppTheme.surfaceElevated,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentOnSurface,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.contactMap,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentOnSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, color: AppTheme.accentOnSurface, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.child,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentOnSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentOnSurface),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.grey,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
