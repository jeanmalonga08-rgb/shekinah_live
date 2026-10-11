import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

String resolveNotificationsApiBaseUrl() {
  const fromEnv = String.fromEnvironment('NOTIF_API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (kIsWeb) return '';
  return AppConstants.notificationsApiBaseUrl;
}
