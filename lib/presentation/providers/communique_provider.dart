import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import '../../data/datasources/communique_remote_datasource.dart';
import '../../domain/entities/communique.dart';

final communiqueDataSourceProvider = Provider<CommuniqueRemoteDataSource>(
  (ref) => CommuniqueRemoteDataSourceImpl(dio: ref.watch(dioProvider)),
);

final communiqueProvider =
    AsyncNotifierProvider<CommuniqueNotifier, List<Communique>>(
  CommuniqueNotifier.new,
);

class CommuniqueNotifier extends AsyncNotifier<List<Communique>> {
  @override
  Future<List<Communique>> build() async {
    return ref.read(communiqueDataSourceProvider).fetchActiveCommuniques();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(communiqueDataSourceProvider).fetchActiveCommuniques(),
    );
  }
}
