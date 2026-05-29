import 'dart:async' show unawaited;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/map_rotation.dart';
import '../providers/settings_provider.dart';
import 'notification_service.dart';

class MapNotificationService {
  MapNotificationService._();

  static void schedule(WidgetRef ref, MapRotation data) {
    final s = ref.read(playerSettingsProvider);
    final anyActive =
        (s.notifyRankedMapRotation && s.rankedNotifyMinutesBefore > 0) ||
        (s.notifyPubsMapRotation && s.pubsNotifyMinutesBefore > 0) ||
        (s.notifyMixtapeMapRotation && s.mixtapeNotifyMinutesBefore > 0) ||
        (s.notifyWildcardMapRotation && s.wildcardNotifyMinutesBefore > 0);
    if (anyActive) {
      unawaited(NotificationService.scheduleAll(
        data,
        notifyRanked: s.notifyRankedMapRotation,
        rankedMinutesBefore: s.rankedNotifyMinutesBefore,
        notifyPubs: s.notifyPubsMapRotation,
        pubsMinutesBefore: s.pubsNotifyMinutesBefore,
        notifyMixtape: s.notifyMixtapeMapRotation,
        mixtapeMinutesBefore: s.mixtapeNotifyMinutesBefore,
        notifyWildcard: s.notifyWildcardMapRotation,
        wildcardMinutesBefore: s.wildcardNotifyMinutesBefore,
        favoriteRankedMapNames: s.favoriteRankedMapNames,
        favoritePubsMapNames: s.favoritePubsMapNames,
      ));
    } else {
      unawaited(NotificationService.cancelAll());
    }
  }
}
