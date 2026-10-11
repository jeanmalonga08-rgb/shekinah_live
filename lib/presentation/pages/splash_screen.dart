import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/network/network_ready.dart';
import '../../core/theme/app_theme.dart';
import '../navigation/notification_navigation.dart';
import '../widgets/sht_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String? _status;

  static const _titleColor = Color(0xFF0F2744);
  static const _subtitleColor = Color(0xFF64748B);
  static const _mutedColor = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    setState(() => _status = context.l10n.splashConnecting);
    await waitForNetwork();

    if (!mounted) return;
    await Navigator.of(context).pushReplacementNamed('/main');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(flushPendingNotificationRoute());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = _status ?? l10n.splashLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const AppLogo(size: 120),
              ),
              const SizedBox(height: 28),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _titleColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.churchTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _subtitleColor,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.homeScriptureBanner,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                    ),
              ),
              const SizedBox(height: 48),
              const SpinKitFadingCircle(color: AppTheme.royalBlue, size: 44),
              const SizedBox(height: 16),
              Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
