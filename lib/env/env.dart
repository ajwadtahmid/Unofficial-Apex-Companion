import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'PROXY_URL')
  static final String proxyUrl = _Env.proxyUrl;

  /// Secondary proxy deployment, tried automatically when [proxyUrl] fails
  /// after retries (see RetryInterceptor). Leave empty to disable failover.
  @EnviedField(varName: 'PROXY_URL_BACKUP', defaultValue: '')
  static final String proxyUrlBackup = _Env.proxyUrlBackup;

  @EnviedField(varName: 'CLIENT_TOKEN')
  static final String clientToken = _Env.clientToken;

  /// Sentry DSN — get from sentry.io → Project Settings → Client Keys.
  /// Leave empty to disable crash reporting (safe for local dev).
  @EnviedField(varName: 'SENTRY_DSN', defaultValue: '')
  static final String sentryDsn = _Env.sentryDsn;
}
