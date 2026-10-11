import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Attend qu'une connectivité réelle soit disponible (DNS opérationnel).
Future<bool> waitForNetwork({
  Duration timeout = const Duration(seconds: 30),
  String probeHost = 'shekinahgospel.org',
}) async {
  final connectivity = Connectivity();
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    final results = await connectivity.checkConnectivity();
    final hasLink = results.any((r) => r != ConnectivityResult.none);
    if (hasLink) {
      try {
        final lookup = await InternetAddress.lookup(probeHost).timeout(
          const Duration(seconds: 5),
        );
        if (lookup.isNotEmpty) return true;
      } catch (_) {
        // DNS pas encore prêt — on réessaie.
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }
  return false;
}

/// Vérifie rapidement si le DNS répond.
Future<bool> isNetworkReady({
  String probeHost = 'shekinahgospel.org',
}) async {
  try {
    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) return false;
    final lookup = await InternetAddress.lookup(probeHost).timeout(
      const Duration(seconds: 4),
    );
    return lookup.isNotEmpty;
  } catch (_) {
    return false;
  }
}
