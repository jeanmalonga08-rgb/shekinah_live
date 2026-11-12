import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pastor_anniversary.dart';
import '../navigation/notification_navigation.dart';

/// Page d'accueil spéciale « 70 ans du Pasteur » affichée
/// entre le splash et l'accueil jusqu'à fin novembre 2026.
/// Passe automatiquement à l'accueil après 5 secondes.
class PastorAnniversaryPage extends StatefulWidget {
  const PastorAnniversaryPage({super.key});

  @override
  State<PastorAnniversaryPage> createState() => _PastorAnniversaryPageState();
}

class _PastorAnniversaryPageState extends State<PastorAnniversaryPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), _continue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/main');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(flushPendingNotificationRoute());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: GestureDetector(
        onTap: _continue,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AppTheme.royalBlue.withValues(alpha: 0.35),
              child: Center(
                child: Icon(Icons.photo, color: AppTheme.accentGold, size: 64),
              ),
            ),
            CachedNetworkImage(
              imageUrl: PastorAnniversary.imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.pastorAnniversaryVerse,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.softWhite,
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 21,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 56,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.accentGold,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.pastorAnniversaryVerseRef,
                      style: TextStyle(
                        color: AppTheme.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.pastorTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.softWhite.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                tooltip: l10n.ok,
                icon: Icon(Icons.close, color: AppTheme.softWhite),
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
