import 'dart:math' show min;

int calculateMinActiveNotificationInterval({
  required bool notifyRanked,
  required int rankedMinutes,
  required bool notifyPubs,
  required int pubsMinutes,
  required bool notifyMixtape,
  required int mixtapeMinutes,
}) {
  final active = [
    if (notifyRanked && rankedMinutes > 0) rankedMinutes,
    if (notifyPubs && pubsMinutes > 0) pubsMinutes,
    if (notifyMixtape && mixtapeMinutes > 0) mixtapeMinutes,
  ];
  return active.isEmpty ? 0 : active.reduce(min);
}
