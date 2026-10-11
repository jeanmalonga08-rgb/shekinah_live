import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

Future<bool> _probeHost(String probeHost) async {
  try {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final response = await dio.head('https://$probeHost');
    return response.statusCode != null && response.statusCode! < 500;
  } catch (_) {
    return false;
  }
}

/// Attend qu'une connectivité réelle soit disponible.
Future<bool> waitForNetwork({
  Duration timeout = const Duration(seconds: 30),
  String probeHost = 'shekinahgospel.org',
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    final results = await Connectivity().checkConnectivity();
    final hasLink = results.any((r) => r != ConnectivityResult.none);
    if (hasLink && await _probeHost(probeHost)) return true;
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }
  return false;
}

/// Vérifie rapidement si le réseau répond.
Future<bool> isNetworkReady({
  String probeHost = 'shekinahgospel.org',
}) async {
  try {
    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) return false;
    return _probeHost(probeHost);
  } catch (_) {
    return false;
  }
}
