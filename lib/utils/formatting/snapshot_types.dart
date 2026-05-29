import 'package:flutter/foundation.dart' show listEquals;
import '../../models/season_meta.dart';

class StatSnapshot {
  final DateTime timestamp;
  final int rp;

  const StatSnapshot({required this.timestamp, required this.rp});

  Map<String, dynamic> toJson() => {
    'ts': timestamp.millisecondsSinceEpoch,
    'rp': rp,
  };

  factory StatSnapshot.fromJson(Map<String, dynamic> json) => StatSnapshot(
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int),
    rp: json['rp'] as int,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatSnapshot && timestamp == other.timestamp && rp == other.rp;

  @override
  int get hashCode => Object.hash(timestamp, rp);
}

/// Returns the RP gained over the last 24 hours.
/// Uses the most recent snapshot from 24+ hours ago as baseline; falls back
/// to the first available snapshot if all data is within the last 24 hours.
int? computeDelta(List<StatSnapshot> snaps, int currentRp) {
  if (snaps.isEmpty) return null;
  final now = DateTime.now();
  final dayAgo = now.subtract(const Duration(days: 1));

  // Find the most recent snapshot from 24+ hours ago.
  StatSnapshot? baseline;
  for (final s in snaps.reversed) {
    if (s.timestamp.isBefore(dayAgo)) {
      baseline = s;
      break;
    }
  }

  // Fall back to the first (oldest) snapshot if all data is within 24h.
  baseline ??= snaps.first;
  return currentRp - baseline.rp;
}

/// Aggregated snapshot metadata for a ranked season.
class SeasonSnapshot {
  final SeasonMeta season;
  final List<StatSnapshot> snapshots;

  const SeasonSnapshot({required this.season, required this.snapshots});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonSnapshot &&
          season == other.season &&
          listEquals(snapshots, other.snapshots);

  @override
  int get hashCode => Object.hash(season, Object.hashAll(snapshots));
}
