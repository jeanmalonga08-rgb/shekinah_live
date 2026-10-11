import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../data/datasources/multimedia_remote_datasource.dart';
import '../../domain/entities/multimedia_video.dart';

final multimediaDataSourceProvider = Provider<MultimediaRemoteDataSource>(
  (ref) => MultimediaRemoteDataSourceImpl(dio: ref.watch(dioProvider)),
);

final documentaireScenetteProvider =
    AsyncNotifierProvider<DocumentaireScenetteNotifier, List<MultimediaVideo>>(
      DocumentaireScenetteNotifier.new,
    );

class DocumentaireScenetteNotifier
    extends AsyncNotifier<List<MultimediaVideo>> {
  @override
  Future<List<MultimediaVideo>> build() {
    return ref
        .read(multimediaDataSourceProvider)
        .fetchDocumentaireScenetteVideos();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(multimediaDataSourceProvider)
          .fetchDocumentaireScenetteVideos(),
    );
  }
}
