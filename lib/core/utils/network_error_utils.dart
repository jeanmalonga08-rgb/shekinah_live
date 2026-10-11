import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/network_guard.dart';
import '../../l10n/app_localizations.dart';

/// Message lisible pour l'utilisateur à partir d'une erreur réseau.
String formatNetworkError(AppLocalizations l10n, Object error) {
  if (error is NetworkUnavailableException) {
    return l10n.networkError;
  }
  if (error is DioException) {
    if (kDebugMode) {
      debugPrint(
        '[Network] ${error.type} ${error.message} '
        'cause=${error.error}',
      );
    }
    switch (error.type) {
      case DioExceptionType.connectionError:
        return l10n.networkError;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return l10n.timeoutError;
      case DioExceptionType.badResponse:
        return l10n.genericError;
      case DioExceptionType.unknown:
        final cause = error.error?.toString() ?? '';
        if (cause.contains('ERR_NAME_NOT_RESOLVED') ||
            cause.contains('Failed host lookup')) {
          return l10n.networkError;
        }
        return l10n.genericError;
      default:
        return l10n.networkError;
    }
  }

  final text = error.toString();
  if (text.contains('NetworkUnavailableException') ||
      text.contains('SocketException') ||
      text.contains('connection error') ||
      text.contains('Connection failed') ||
      text.contains('Failed host lookup') ||
      text.contains('Network is unreachable') ||
      text.contains('No address associated')) {
    return l10n.networkError;
  }
  if (text.contains('TimeoutException') || text.contains('timed out')) {
    return l10n.timeoutError;
  }
  return l10n.genericError;
}
