import 'dart:typed_data';

import 'package:apexlytics/utils/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fakes the transport layer only, so requests still flow through the real
/// [Dio] pipeline (and therefore the real [RetryInterceptor]) rather than
/// mocking Dio's own internals, which the package deliberately doesn't
/// expose for testing (InterceptorState/InterceptorResultType are hidden
/// from the public API).
class _FakeAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) onFetch;
  _FakeAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => onFetch(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _status(int code) =>
    ResponseBody.fromString('', code, headers: {});

void main() {
  const primary = 'https://primary.test';
  const backup = 'https://backup.test';

  Dio buildDio({
    required Future<ResponseBody> Function(RequestOptions) onFetch,
    int maxRetries = 2,
    String? backupBaseUrl,
  }) {
    final dio = Dio(BaseOptions(baseUrl: primary));
    dio.httpClientAdapter = _FakeAdapter(onFetch);
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: maxRetries,
        initialDelay: Duration.zero,
        backupBaseUrl: backupBaseUrl,
      ),
    );
    return dio;
  }

  test('non-retryable errors (e.g. 404) are not retried at all', () async {
    var calls = 0;
    final dio = buildDio(
      onFetch: (o) async {
        calls++;
        return _status(404);
      },
    );

    await expectLater(dio.get('/player'), throwsA(isA<DioException>()));
    expect(calls, 1);
  });

  test(
    'retries the same host up to maxRetries, then gives up without a backup',
    () async {
      var calls = 0;
      final dio = buildDio(
        maxRetries: 2,
        onFetch: (o) async {
          calls++;
          return _status(503);
        },
      );

      await expectLater(dio.get('/player'), throwsA(isA<DioException>()));
      expect(calls, 3); // initial attempt + 2 retries
    },
  );

  test('fails over to the backup host once retries are exhausted', () async {
    final calledBaseUrls = <String>[];
    final dio = buildDio(
      maxRetries: 1,
      backupBaseUrl: backup,
      onFetch: (o) async {
        calledBaseUrls.add(o.baseUrl);
        return o.baseUrl == backup ? _status(200) : _status(503);
      },
    );

    final response = await dio.get('/player');

    expect(response.statusCode, 200);
    // Primary gets its full retry budget (2 calls) before the backup (1 call).
    expect(calledBaseUrls, [primary, primary, backup]);
  });

  test('never bounces back to primary if the backup also fails', () async {
    final calledBaseUrls = <String>[];
    final dio = buildDio(
      maxRetries: 0,
      backupBaseUrl: backup,
      onFetch: (o) async {
        calledBaseUrls.add(o.baseUrl);
        return _status(503);
      },
    );

    await expectLater(dio.get('/player'), throwsA(isA<DioException>()));
    // One attempt at the primary, one at the backup, then it gives up —
    // never a second round back at the primary.
    expect(calledBaseUrls, [primary, backup]);
  });
}
