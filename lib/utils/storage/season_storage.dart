import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/prefs_keys.dart';
import '../../models/season_meta.dart';

Map<String, SeasonMeta> _parseSeasons(String? raw) {
  if (raw == null) return {};
  try {
    final list = jsonDecode(raw) as List;
    final result = <String, SeasonMeta>{};
    for (final item in list.whereType<Map<String, dynamic>>()) {
      final meta = SeasonMeta.fromJson(item);
      result[meta.id] = meta;
    }
    return result;
  } on FormatException {
    return {};
  }
}

/// Returns all stored seasons, newest first.
Map<String, SeasonMeta> loadAllSeasonsSync(SharedPreferences prefs) =>
    _parseSeasons(prefs.getString(PrefsKeys.seasonHistory));

/// Adds or updates [season] in storage. No-op if start/end are unchanged.
Future<void> upsertSeason(
  SeasonMeta season,
  SharedPreferences prefs,
) async {
  final existing = loadAllSeasonsSync(prefs);
  final prev = existing[season.id];
  if (prev != null &&
      prev.start == season.start &&
      prev.end == season.end) {
    return;
  }
  existing[season.id] = season;
  await prefs.setString(
    PrefsKeys.seasonHistory,
    jsonEncode(existing.values.map((s) => s.toJson()).toList()),
  );
}
