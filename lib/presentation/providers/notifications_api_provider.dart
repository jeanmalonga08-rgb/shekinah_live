import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/services/installation_id_service.dart';

final notificationsApiDioProvider = Provider((ref) => createNotificationsApiDio());

final notificationsDataSourceProvider = Provider<NotificationsRemoteDataSource>(
  (ref) => NotificationsRemoteDataSourceImpl(
    dio: ref.watch(notificationsApiDioProvider),
  ),
);

final installationIdProvider = FutureProvider<String>(
  (ref) async {
    final _ = ref;
    return InstallationIdService.getOrCreate();
  },
);
