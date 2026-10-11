import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_provider.dart';
import '../../data/datasources/live_stream_remote_datasource.dart';
import '../../data/repositories/live_stream_repository_impl.dart';
import '../../domain/entities/live_status.dart';
import '../../domain/repositories/live_stream_repository.dart';
import '../../domain/usecases/check_live_status_usecase.dart';

// Provider pour le remote data source
final liveStreamRemoteDataSourceProvider = Provider<LiveStreamRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return LiveStreamRemoteDataSourceImpl(dio: dio);
});

// Provider pour le repository
final liveStreamRepositoryProvider = Provider<LiveStreamRepository>((ref) {
  final remoteDataSource = ref.watch(liveStreamRemoteDataSourceProvider);
  return LiveStreamRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Provider pour le use case
final checkLiveStatusUseCaseProvider = Provider<CheckLiveStatusUseCase>((ref) {
  final repository = ref.watch(liveStreamRepositoryProvider);
  return CheckLiveStatusUseCase(repository);
});

// Provider principal pour l'état du live stream
final liveStreamProvider = StateNotifierProvider<LiveStreamNotifier, LiveStreamState>((ref) {
  final checkLiveStatusUseCase = ref.watch(checkLiveStatusUseCaseProvider);
  return LiveStreamNotifier(checkLiveStatusUseCase);
});

// État du live stream
class LiveStreamState {
  final LiveStreamEntity? liveStream;
  final bool isLoading;
  final String? errorMessage;

  const LiveStreamState({
    this.liveStream,
    this.isLoading = false,
    this.errorMessage,
  });

  LiveStreamState copyWith({
    LiveStreamEntity? liveStream,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LiveStreamState(
      liveStream: liveStream ?? this.liveStream,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLive => liveStream?.status == LiveStatus.live;
  bool get isOffline => liveStream?.status == LiveStatus.offline;
  bool get hasError => errorMessage != null;
}

// Notifier pour gérer les actions
class LiveStreamNotifier extends StateNotifier<LiveStreamState> {
  LiveStreamNotifier(this._checkLiveStatusUseCase) : super(const LiveStreamState()) {
    unawaited(checkLiveStatus());
  }

  final CheckLiveStatusUseCase _checkLiveStatusUseCase;
  Timer? _pollTimer;
  bool _refreshInFlight = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }

  void _schedulePoll() {
    if (_disposed) return;
    _pollTimer?.cancel();
    final interval = state.isLive
        ? AppConstants.liveRefreshIntervalLive
        : AppConstants.liveRefreshIntervalOffline;
    _pollTimer = Timer(interval, () {
      unawaited(_pollLiveStatus());
    });
  }

  Future<void> _pollLiveStatus() async {
    if (_disposed || _refreshInFlight) {
      _schedulePoll();
      return;
    }

    _refreshInFlight = true;
    try {
      final result = await _checkLiveStatusUseCase.call();
      if (_disposed) return;
      result.fold(
        (_) {},
        (liveStream) {
          state = state.copyWith(
            liveStream: liveStream,
            errorMessage: null,
          );
        },
      );
    } finally {
      _refreshInFlight = false;
      _schedulePoll();
    }
  }

  Future<void> checkLiveStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _checkLiveStatusUseCase.call();

    if (_disposed) return;
    result.fold(
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error,
        );
      },
      (liveStream) {
        state = state.copyWith(
          isLoading: false,
          liveStream: liveStream,
        );
      },
    );
    _schedulePoll();
  }

  Future<void> refreshLiveStatus() async {
    await checkLiveStatus();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
