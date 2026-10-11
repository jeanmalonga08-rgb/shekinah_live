import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_shared.dart';

/// Client HTTP partagé pour le Web (sans dart:io).
final dioProvider = Provider<Dio>((ref) {
  final dio = createBaseDio();

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        logPrint: (message) => debugPrint('[HTTP] $message'),
      ),
    );
  }

  dio.interceptors.add(RetryInterceptor(dio));
  return dio;
});
