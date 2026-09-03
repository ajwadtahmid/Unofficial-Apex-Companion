import 'dart:math';

import 'package:dio/dio.dart';

import 'app_logger.dart';

const _kRetryKey = '_retry_count';
const _kUsedBackupKey = '_used_backup';

/// Retries requests on transient server errors (5xx) and network failures.
///
/// Uses exponential backoff — delays are [initialDelay] * 2^attempt:
///   attempt 0 → wait 1s, attempt 1 → wait 2s  (for default maxRetries=2)
///
/// The retry count is stored in [RequestOptions.extra] so it survives the
/// interceptor chain without any external state.
///
/// If [backupBaseUrl] is set and every retry against the primary host still
/// fails, the same request is reissued once against it (with its own fresh
/// retry budget) before giving up — this is what covers a primary host that's
/// asleep or down, e.g. a free-tier server that spins down.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final String? backupBaseUrl;

  const RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.initialDelay = const Duration(seconds: 1),
    this.backupBaseUrl,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra[_kRetryKey] as int?) ?? 0;

    if (attempt < maxRetries) {
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
      return _refetch(err, handler);
    }

    // Retries against the current host are exhausted. Fail over to the
    // backup host exactly once — its own retries are tracked separately so
    // it gets the same retry budget the primary just used, and the
    // [_kUsedBackupKey] flag stops this from ever bouncing back and forth.
    final usedBackup = err.requestOptions.extra[_kUsedBackupKey] == true;
    final backup = backupBaseUrl;
    if (!usedBackup && backup != null && backup.isNotEmpty) {
      log.w(
        'Primary proxy failed after $maxRetries retries, trying backup '
        'for ${err.requestOptions.path}',
      );
      err.requestOptions
        ..baseUrl = backup
        ..extra[_kUsedBackupKey] = true
        ..extra[_kRetryKey] = 0;
      return _refetch(err, handler);
    }

    return handler.next(err);
  }

  Future<void> _refetch(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
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
