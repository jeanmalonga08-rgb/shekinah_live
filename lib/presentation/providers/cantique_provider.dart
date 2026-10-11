import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';
import '../../core/network/network_guard.dart';
import '../../data/datasources/cantique_remote_datasource.dart';
import '../../domain/entities/cantique.dart';

final cantiqueDataSourceProvider = Provider<CantiqueRemoteDataSource>(
  (ref) => CantiqueRemoteDataSourceImpl(dio: ref.watch(dioProvider)),
);

final cantiqueListProvider =
    AsyncNotifierProvider<CantiqueListNotifier, List<Cantique>>(
  CantiqueListNotifier.new,
);

class CantiqueListNotifier extends AsyncNotifier<List<Cantique>> {
  @override
  Future<List<Cantique>> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<Cantique>> _fetch() async {
    await ensureNetworkReady();
    return ref.read(cantiqueDataSourceProvider).fetchCantiques();
  }
}
