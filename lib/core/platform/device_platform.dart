import 'device_platform_io.dart'
    if (dart.library.html) 'device_platform_web.dart';

/// Code plateforme attendu par l'API : 1=Android, 2=iOS, 3=Web.
int get devicePlatformCode => resolveDevicePlatformCode();
