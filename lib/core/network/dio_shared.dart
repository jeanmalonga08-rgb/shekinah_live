import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

Dio createBaseDio() {
  return Dio(
    BaseOptions(
      connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'User-Agent': AppConstants.userAgent,
        'Accept': 'application/json',
      },
      followRedirects: true,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    ),
  );
}

class RetryInterceptor extends Interceptor {
  RetryInterceptor(Dio dio)
      : _retryDio = Dio(dio.options)..httpClientAdapter = dio.httpClientAdapter;

  final Dio _retryDio;

  static const _maxRetries = 4;
  static const _retryKey = 'retry_count';
  static const _retryDelaysMs = [800, 1600, 3200, 5000];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final count = (err.requestOptions.extra[_retryKey] as int?) ?? 0;
    if (count < _maxRetries && _shouldRetry(err)) {
      err.requestOptions.extra[_retryKey] = count + 1;
      final delayMs = _retryDelaysMs[count.clamp(0, _retryDelaysMs.length - 1)];
      await Future<void>.delayed(Duration(milliseconds: delayMs));
      try {
        final response = await _retryDio.fetch<dynamic>(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (retryError) {
        handler.next(retryError);
        return;
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    if (err.type == DioExceptionType.unknown) {
      final cause = err.error?.toString() ?? '';
      return cause.contains('ERR_NAME_NOT_RESOLVED') ||
          cause.contains('Failed host lookup') ||
          cause.contains('Network is unreachable');
    }
    return false;
  }
}
