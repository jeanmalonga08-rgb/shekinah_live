import 'notifications_api_config_io.dart'
    if (dart.library.html) 'notifications_api_config_web.dart';

/// URL de base de l'API notifications (`api_notif_live`).
///
/// Production : [AppConstants.notificationsApiBaseUrl]
/// Surcharge locale : `--dart-define=NOTIF_API_URL=http://192.168.x.x:5170`
String get notificationsApiBaseUrl => resolveNotificationsApiBaseUrl();

bool get notificationsApiEnabled => notificationsApiBaseUrl.isNotEmpty;
