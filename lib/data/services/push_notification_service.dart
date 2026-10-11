import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/network/notifications_api_config.dart';
import '../../core/platform/device_platform.dart';
import '../../data/services/fcm_token_cache.dart';
import '../../data/services/installation_id_service.dart';
import '../../presentation/navigation/notification_navigation.dart';
import '../../presentation/providers/app_update_provider.dart';
import '../../presentation/providers/locale_provider.dart';
import '../../presentation/providers/notifications_api_provider.dart';
import '../../presentation/providers/notifications_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb || !notificationsApiEnabled) return;
    _initialized = true;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.setAutoInitEnabled(true);

      FirebaseMessaging.onMessage.listen((message) {
        _ref.invalidate(notificationsListProvider);
        _ref.invalidate(notificationsUnreadCountProvider);
        final type = message.data['type']?.toString().toLowerCase() ?? '';
        final refType = message.data['ref_type']?.toString().toLowerCase() ?? '';
        if (type.contains('appupdate') || refType == 'app_update') {
          _ref.invalidate(appUpdatePromptProvider);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _handleRemoteMessage(initial);
      }

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[Push] Permission refusée');
        return;
      }

      await _subscribeTopics(messaging);
      await _registerWithApi(messaging);

      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        await FcmTokenCache.save(token);
        await _updateToken(token);
      });
    } catch (e, st) {
      debugPrint('[Push] Init failed: $e\n$st');
    }
  }

  Future<void> _subscribeTopics(FirebaseMessaging messaging) async {
    for (final topic in const [
      'all',
      'live',
      'predications',
      'cantiques',
      'communiques',
    ]) {
      try {
        await messaging.subscribeToTopic(topic);
      } catch (e) {
        debugPrint('[Push] Topic $topic: $e');
      }
    }
  }

  Future<void> _registerWithApi(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) return;

    await FcmTokenCache.save(token);

    final installationId = await InstallationIdService.getOrCreate();
    final ds = _ref.read(notificationsDataSourceProvider);
    final locale = _ref.read(localeProvider)?.languageCode ?? 'fr';
    final info = await PackageInfo.fromPlatform();

    await ds.registerDevice(
      installationId: installationId,
      fcmToken: token,
      platform: devicePlatformCode,
      locale: locale,
      appVersion: info.version,
    );

    _ref.invalidate(notificationsListProvider);
    _ref.invalidate(notificationsUnreadCountProvider);
  }

  Future<void> _updateToken(String token) async {
    await FcmTokenCache.save(token);
    final installationId = await InstallationIdService.getOrCreate();
    final ds = _ref.read(notificationsDataSourceProvider);
    final locale = _ref.read(localeProvider)?.languageCode ?? 'fr';
    final info = await PackageInfo.fromPlatform();

    await ds.updateToken(
      installationId: installationId,
      fcmToken: token,
      appVersion: info.version,
      locale: locale,
    );
  }

  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    final route = resolvePushNotificationRoute(message.data);
    if (route == null || route.isEmpty) return;
    final refType = message.data['ref_type']?.toString();
    await openNotificationRoute(
      route: route,
      refType: refType,
      refId: message.data['ref_id']?.toString(),
      resolveAppUpdateStoreUrl: _resolveAppUpdateStoreUrl,
    );
    _ref.invalidate(notificationsListProvider);
    _ref.invalidate(notificationsUnreadCountProvider);
    if ((refType ?? '').toLowerCase() == 'app_update' ||
        (message.data['type']?.toString().toLowerCase() ?? '')
            .contains('appupdate')) {
      _ref.invalidate(appUpdatePromptProvider);
    }
  }

  Future<String?> _resolveAppUpdateStoreUrl() async {
    try {
      final remote =
          await _ref.read(appUpdateRemoteDataSourceProvider).fetchUpdateInfo();
      if (remote == null) return defaultAppUpdateStoreUrl();
      if (!kIsWeb && Platform.isIOS) {
        final ios = remote.iosStoreUrl;
        if (ios != null && ios.isNotEmpty) return ios;
        return null;
      }
      if (remote.androidStoreUrl.isNotEmpty) return remote.androidStoreUrl;
    } catch (e) {
      debugPrint('[Push] resolve store url: $e');
    }
    return defaultAppUpdateStoreUrl();
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  PushNotificationService.new,
);
