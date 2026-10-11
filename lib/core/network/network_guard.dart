import 'network_ready.dart';

/// Levée lorsque l'appareil n'a pas de connexion internet utilisable.
class NetworkUnavailableException implements Exception {
  const NetworkUnavailableException();

  @override
  String toString() => 'NetworkUnavailableException';
}

/// Vérifie la connexion avant un chargement distant.
/// Lance [NetworkUnavailableException] si le réseau n'est pas prêt.
Future<void> ensureNetworkReady({
  String probeHost = 'shekinahgospel.org',
}) async {
  if (!await isNetworkReady(probeHost: probeHost)) {
    throw const NetworkUnavailableException();
  }
}
