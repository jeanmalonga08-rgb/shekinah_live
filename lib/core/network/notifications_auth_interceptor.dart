import 'package:dio/dio.dart';
import '../../data/services/fcm_token_cache.dart';
import '../../data/services/installation_id_service.dart';

const installationIdHeader = 'X-Installation-Id';
const fcmTokenHeader = 'X-Fcm-Token';

/// Ajoute les headers de sécurité device (installation + token FCM).
Interceptor notificationsAuthInterceptor() => InterceptorsWrapper(
      onRequest: (options, handler) async {
        final installationId = await InstallationIdService.getOrCreate();
        final fcmToken = await FcmTokenCache.load();
        options.headers[installationIdHeader] = installationId;
        if (fcmToken != null && fcmToken.isNotEmpty) {
          options.headers[fcmTokenHeader] = fcmToken;
        }
        handler.next(options);
      },
    );
