import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/live_status.dart';
import '../../domain/repositories/live_stream_repository.dart';
import '../datasources/live_stream_remote_datasource.dart';

class LiveStreamRepositoryImpl implements LiveStreamRepository {
  LiveStreamRepositoryImpl({required this.remoteDataSource});

  final LiveStreamRemoteDataSource remoteDataSource;

  @override
  Future<Either<String, LiveStreamEntity>> checkLiveStatus() async {
    try {
      final entity = await remoteDataSource.fetchLiveSettings();
      return Right(entity);
    } catch (_) {
      return const Left('');
    }
  }

  @override
  String getStreamUrl() {
    // Conservé pour compatibilité ; le player utilise embedUrlFor(lang).
    return AppConstants.liveStreamUrl;
  }

  @override
  Future<bool> isLiveCurrently() async {
    try {
      final entity = await remoteDataSource.fetchLiveSettings();
      return entity.isLive;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Either<String, LiveStreamEntity>> refreshLiveStatus() {
    return checkLiveStatus();
  }
}
