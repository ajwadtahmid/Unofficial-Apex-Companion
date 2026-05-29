import 'dart:math';

import 'package:dio/dio.dart';

import 'app_logger.dart';

const _kRetryKey = '_retry_count';

/// Retries requests on transient server errors (5xx) and network failures.
///
/// Uses exponential backoff — delays are [initialDelay] * 2^attempt:
///   attempt 0 → wait 1s, attempt 1 → wait 2s  (for default maxRetries=2)
///
/// The retry count is stored in [RequestOptions.extra] so it survives the
/// interceptor chain without any external state.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  const RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.initialDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_kRetryKey] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }

    // Exponential backoff with max ceiling of maxRetries. Attempt counter tracked in
    // RequestOptions.extra[_kRetryKey] so it persists across the interceptor chain.
    final delay = initialDelay * pow(2, attempt).toInt();
    log.w(
      'Retry ${attempt + 1}/$maxRetries for ${err.requestOptions.path} '
      'in ${delay.inMilliseconds}ms '
      '(${err.response?.statusCode ?? err.type.name})',
    );

    await Future.delayed(delay);

    err.requestOptions.extra[_kRetryKey] = attempt + 1;
    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    final status = err.response?.statusCode;
    if (status != null && status >= 500) return true;
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }
}
