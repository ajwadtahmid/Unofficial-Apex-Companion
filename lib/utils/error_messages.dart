import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

String friendlyError(Object? error) {
  if (error is AppException) return error.message;
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
          'Request timed out. The server may be waking up — try again in a moment.',
      DioExceptionType.connectionError =>
          'No connection. Check your internet and try again.',
      _ => switch (error.response?.statusCode) {
        400 => 'Bad request. Try again in a few minutes.',
        401 => 'Unauthorized. Check your proxy configuration.',
        403 => 'Access denied.',
        404 => 'Player not found. Check the name and platform.',
        410 => 'Unknown platform. Use PC, PS4, X1, or SWITCH.',
        429 => 'Rate limit reached. Wait a moment and try again.',
        500 => 'Server error. Try again later.',
        502 || 503 => 'Service unavailable. The proxy or Apex API may be down.',
        _ => 'Network error (${error.response?.statusCode ?? "unknown"}).',
      },
    };
  }
  return error?.toString() ?? 'Unknown error';
}
