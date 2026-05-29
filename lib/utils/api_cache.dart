import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResult<T> {
  final T data;
  final DateTime? staleAt;
  const ApiResult(this.data, {this.staleAt});
}

class CachedEntry {
  final dynamic data;
  final DateTime savedAt;
  const CachedEntry({required this.data, required this.savedAt});
}

/// Per-endpoint TTL overrides (in minutes). Endpoints not listed fall back to
/// [ApiCache.defaultMaxAgeMinutes].
const Map<String, int> kEndpointCacheTtlMinutes = {
  '/predator': 60,
  '/servers': 5,
  '/maprotation': 15,
};

class ApiCache {
  final SharedPreferences _prefs;
  static const _cacheKeyPrefix = 'api_cache:';
  static const _cacheTimestampKeyPrefix = 'api_cache_ts:';
  // Default TTL: 24 h — useful offline but overridden per endpoint above.
  static const defaultMaxAgeMinutes = 24 * 60;

  ApiCache(this._prefs);

  /// Saves [data] with a timestamp. Returns null if the entry has exceeded its TTL.
  Future<void> save(String key, dynamic data) async {
    await _prefs.setString('$_cacheKeyPrefix$key', jsonEncode(data));
    await _prefs.setInt(
      '$_cacheTimestampKeyPrefix$key',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Loads cached data by [key]. Returns null if not found or expired past the endpoint's TTL.
  CachedEntry? load(String key) {
    final raw = _prefs.getString('$_cacheKeyPrefix$key');
    final ts = _prefs.getInt('$_cacheTimestampKeyPrefix$key');
    if (raw == null || ts == null) return null;
    final savedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    final ttl = _ttlForKey(key);
    // Millisecond epoch comparison: timezone-safe because both sides use the same
    // internal clock reference regardless of local time zone.
    if (DateTime.now().difference(savedAt).inMinutes > ttl) return null;
    try {
      return CachedEntry(data: jsonDecode(raw), savedAt: savedAt);
    } on FormatException {
      return null;
    }
  }

  /// Resolves TTL by matching the key against [kEndpointCacheTtlMinutes].
  /// Keys are cache keys (endpoint + params), so we match on prefix.
  static int _ttlForKey(String key) {
    for (final entry in kEndpointCacheTtlMinutes.entries) {
      if (key.startsWith(entry.key)) return entry.value;
    }
    return defaultMaxAgeMinutes;
  }
}
