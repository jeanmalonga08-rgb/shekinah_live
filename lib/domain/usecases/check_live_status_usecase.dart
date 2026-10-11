import 'package:dartz/dartz.dart';
import '../entities/live_status.dart';
import '../repositories/live_stream_repository.dart';

class CheckLiveStatusUseCase {
  final LiveStreamRepository _repository;

  CheckLiveStatusUseCase(this._repository);

  Future<Either<String, LiveStreamEntity>> call() async {
    return await _repository.checkLiveStatus();
  }
}
