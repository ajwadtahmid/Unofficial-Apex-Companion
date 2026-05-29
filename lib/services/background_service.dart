import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:background_fetch/background_fetch.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../constants/api_constants.dart';
import '../constants/timeout_constants.dart';
import '../env/env.dart';
import '../models/background_fetch_settings.dart';
import '../models/map_rotation.dart';
import '../utils/app_logger.dart';
import 'notification_service.dart';

const int _backgroundFetchIntervalMinutes = 30;

// Runs when the app is fully terminated (headless). Must be top-level.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessEvent event) async {
  if (event.timeout) {
    // Headless isolate — use debugPrint since logger/Sentry may not be initialised.
    debugPrint('[BackgroundService] Task timed out: ${event.taskId}');
    BackgroundFetch.finish(event.taskId);
    return;
  }
  try {
    await _backgroundFetchAndSchedule();
  } finally {
    BackgroundFetch.finish(event.taskId);
  }
}

Future<void> _backgroundFetchAndSchedule() async {
  try {
    debugPrint('[BackgroundService] Fetch started');
    tz.initializeTimeZones();
    await NotificationService.init();

    final prefs = await SharedPreferences.getInstance();
    final settings = BackgroundFetchSettings.fromPrefs(prefs);
    if (settings == null) return;

    final clientToken = Env.clientToken;
    // Headless tasks run in a detached isolate — no provider tree is available,
    // so ApiService cannot be used here. Create a minimal Dio client directly.
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.proxyUrl,
        connectTimeout: TimeoutConstants.apiConnect,
        receiveTimeout: TimeoutConstants.apiReceive,
        headers: clientToken.isNotEmpty ? {'x-client-token': clientToken} : {},
      ),
    );

    final response = await dio.get(
      ApiConstants.mapRotationPath,
      queryParameters: {'version': ApiConstants.mapRotationVersion},
    );

    final rotation = MapRotation.fromJson(
      response.data as Map<String, dynamic>,
    );

    await NotificationService.scheduleAll(
      rotation,
      notifyPubs: settings.notifyPubs,
      pubsMinutesBefore: settings.pubsMinutesBefore,
      notifyRanked: settings.notifyRanked,
      rankedMinutesBefore: settings.rankedMinutesBefore,
      notifyMixtape: settings.notifyMixtape,
      mixtapeMinutesBefore: settings.mixtapeMinutesBefore,
      notifyWildcard: settings.notifyWildcard,
      wildcardMinutesBefore: settings.wildcardMinutesBefore,
      favoriteRankedMapNames: settings.favoriteRankedMapNames,
      favoritePubsMapNames: settings.favoritePubsMapNames,
    );
    debugPrint('[BackgroundService] Notifications scheduled successfully');
  } catch (e) {
    // Headless isolate — Sentry is never initialised here (no runApp/main path),
    // so debugPrint is the only available output. Release builds suppress it;
    // this is acceptable since the worst outcome is a missed notification.
    debugPrint('[BackgroundService] Fetch failed: $e');
  }
}

class BackgroundService {
  static bool get _supported => Platform.isAndroid || Platform.isIOS;

  static BackgroundFetchConfig _config(int intervalMinutes) =>
      BackgroundFetchConfig(
        minimumFetchInterval: intervalMinutes,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
      );

  static Future<void> _configure(int intervalMinutes) =>
      BackgroundFetch.configure(
        _config(intervalMinutes),
        (String taskId) async {
          try {
            await _backgroundFetchAndSchedule();
          } finally {
            BackgroundFetch.finish(taskId);
          }
        },
        // Timeout handler — invoked if the task doesn't finish within the deadline.
        (String taskId) => BackgroundFetch.finish(taskId),
      );

  static Future<void> init() async {
    if (!_supported) return;
    await _configure(_backgroundFetchIntervalMinutes);
    if (Platform.isAndroid) {
      BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    }
    log.i('BackgroundService initialised (interval: ${_backgroundFetchIntervalMinutes}min)');
  }

  /// Reconfigures the background fetch interval to the smallest active
  /// notification timing. Pass [minNotifyMinutes] == 0 to fall back to the
  /// default 30-min cadence.
  static Future<void> updateInterval(int minNotifyMinutes) async {
    if (!_supported) return;
    // iOS and Android enforce a 15-min minimum for background fetch — values
    // below 15 (e.g. user picks 5 or 10 min) are silently rounded up by the OS.
    final interval = minNotifyMinutes > 0
        ? minNotifyMinutes.clamp(15, 60)
        : _backgroundFetchIntervalMinutes;
    await _configure(interval);
    log.i('BackgroundService interval updated to ${interval}min');
  }

  /// Returns true if background fetch is available.
  /// On Android this is always true. On iOS it depends on the system setting.
  static Future<bool> isAvailable() async {
    if (!_supported) return false;
    final status = await BackgroundFetch.status;
    return status == BackgroundFetch.STATUS_AVAILABLE;
  }
}
