import 'package:dartz/dartz.dart';
import '../entities/live_status.dart';

abstract class LiveStreamRepository {
  /// Vérifie le statut du live streaming
  Future<Either<String, LiveStreamEntity>> checkLiveStatus();
  
  /// Récupère l'URL du streaming
  String getStreamUrl();
  
  /// Vérifie si un live est en cours
  Future<bool> isLiveCurrently();
  
  /// Actualise le statut du live
  Future<Either<String, LiveStreamEntity>> refreshLiveStatus();
}
