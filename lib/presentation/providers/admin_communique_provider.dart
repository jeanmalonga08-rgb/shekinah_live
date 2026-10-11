import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_communique_remote_data_source.dart';
import '../../domain/entities/admin_communique.dart';
import 'notifications_api_provider.dart';

final adminCommuniqueDataSourceProvider =
    Provider<AdminCommuniqueRemoteDataSource>(
  (ref) => AdminCommuniqueRemoteDataSource(
    dio: ref.watch(notificationsApiDioProvider),
  ),
);

final adminSessionProvider = StateProvider<AdminSession?>((ref) => null);