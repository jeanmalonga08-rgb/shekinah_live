import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'dio_shared.dart';

/// Client HTTP partagé (dart:io) avec retries au démarrage Android.
final dioProvider = Provider<Dio>((ref) {
  final dio = createBaseDio();

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.userAgent = AppConstants.userAgent;
      return client;
    },
  );

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
