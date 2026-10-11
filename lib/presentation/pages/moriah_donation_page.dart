import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Formulaire Flexpaie — campagne reconstruction Temple Moriah.
class MoriahDonationPage extends StatefulWidget {
  const MoriahDonationPage({super.key});

  @override
  State<MoriahDonationPage> createState() => _MoriahDonationPageState();
}

class _MoriahDonationPageState extends State<MoriahDonationPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  bool _isFlexpaieHost(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == 'shekinah.flexpaie.com' || host.endsWith('.flexpaie.com');
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(AppConstants.userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (_isFlexpaieHost(uri)) return NavigationDecision.navigate;
            launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.flexpaieDonationUrl));
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(AppConstants.flexpaieDonationUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.sinistreSupportReconstruction,
          style: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: AppTheme.white,
        iconTheme: IconThemeData(color: AppTheme.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: l10n.website,
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            ColoredBox(
              color: AppTheme.background,
              child: Center(
                child: SpinKitFadingCircle(
                  color: AppTheme.accentOnSurface,
                  size: 44,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
