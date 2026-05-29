import 'dart:math' show min;

int calculateMinActiveNotificationInterval({
  required bool notifyRanked,
  required int rankedMinutes,
  required bool notifyPubs,
  required int pubsMinutes,
  required bool notifyMixtape,
  required int mixtapeMinutes,
  required bool notifyWildcard,
  required int wildcardMinutes,
}) {
  final active = [
    if (notifyRanked && rankedMinutes > 0) rankedMinutes,
    if (notifyPubs && pubsMinutes > 0) pubsMinutes,
    if (notifyMixtape && mixtapeMinutes > 0) mixtapeMinutes,
    if (notifyWildcard && wildcardMinutes > 0) wildcardMinutes,
  ];
  return active.isEmpty ? 0 : active.reduce(min);
}
