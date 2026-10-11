import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pdfrx/pdfrx.dart';
import 'core/audio/background_audio_init.dart';
import 'core/l10n/locale_format.dart';
import 'core/navigation/app_navigator.dart';
import 'core/network/notifications_api_config.dart';
import 'core/platform/offline_playback_platform.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_sync.dart';
import 'core/constants/app_constants.dart';
import 'data/services/push_notification_service.dart';
import 'l10n/app_localizations.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/notifications_provider.dart';
import 'presentation/providers/theme_mode_provider.dart';
import 'presentation/widgets/main_navigation.dart';
import 'presentation/widgets/top_task_banners.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackgroundAudio();
  ensureOfflineVideoBackend();
  pdfrxFlutterInitialize();
  await ensureLocaleFormatInitialized();

  if (!kIsWeb && notificationsApiEnabled) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushNotificationServiceProvider).initialize();
      ref.invalidate(notificationsUnreadCountProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  void _syncTheme(ThemeMode themeMode, Brightness platform) {
    ThemeController.sync(themeMode: themeMode, platform: platform);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider) ?? const Locale('fr', 'FR');
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    _syncTheme(themeMode, platformBrightness);

    return MaterialApp(
      title: AppConstants.appName,
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        _syncTheme(themeMode, MediaQuery.platformBrightnessOf(context));
        return ThemeSync(
          isLight: ThemeController.isLight,
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const TopTaskBanners(),
            ],
          ),
        );
      },
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/main': (context) => const MainNavigation(),
      },
    );
  }
}
