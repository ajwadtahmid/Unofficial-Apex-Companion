import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/api_constants.dart';
import '../../models/player_stats.dart';
import '../../providers/api_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/search_provider.dart';
import '../../utils/formatting/format.dart' show formatNumber;
import '../../utils/formatting/rank_utils.dart' show rankAssetPath, rankLabel;
import '../../utils/formatting/search_utils.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';

class FavoritesPane extends ConsumerWidget {
  final ValueChanged<PlayerRef> onPick;
  const FavoritesPane({super.key, required this.onPick});

  static const _kRefreshConcurrency = 5;

  Future<void> _refreshAll(WidgetRef ref, List<PlayerRef> favorites) async {
    final service = ref.read(playerServiceProvider);
    // Process in batches to avoid saturating the API with concurrent requests.
    for (var i = 0; i < favorites.length; i += _kRefreshConcurrency) {
      final batch = favorites.skip(i).take(_kRefreshConcurrency);
      await Future.wait(
        batch.map((fav) {
          final byUid = fav.hasUid;
          final query = byUid ? fav.uid! : fav.query;
          return refreshAndMarkSynced(ref, service, query, fav.platform, byUid);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(searchStateProvider).favorites;

    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'Search for a player above to get started',
          style: TextStyle(color: AppTheme.muted),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () => _refreshAll(ref, favorites),
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.md),
        children: [
          const _ListHeader(title: 'Favorites'),
          ...favorites.map(
            (r) => _FavoriteTile(playerRef: r, onTap: () => onPick(r)),
          ),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final String title;
  const _ListHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sm),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  final PlayerRef playerRef;
  final VoidCallback onTap;

  const _FavoriteTile({required this.playerRef, required this.onTap});

  String _sessionKey() {
    if (playerRef.uid != null && playerRef.uid!.isNotEmpty) {
      return playerRef.uid!;
    }
    return playerSessionKey(playerRef.platform, playerRef.query);
  }

  /// Returns cached stats or null if not available.
  PlayerStats? _getCachedStats(WidgetRef ref) {
    final service = ref.watch(playerServiceProvider);
    final byUid = playerRef.hasUid;
    final query = byUid ? playerRef.uid! : playerRef.query;

    return service.getCachedStats(
      query,
      playerRef.platform,
      searchByUid: byUid,
    )?.data;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final synced = ref.watch(sessionRefreshedProvider).contains(_sessionKey());
    final platformLabel = ApiConstants.labelFor(playerRef.platform);

    String title;
    Color leadingColor;
    Widget subtitle;

    if (!synced) {
      final cachedStats = _getCachedStats(ref);
      leadingColor = AppTheme.muted;

      if (cachedStats == null) {
        title = playerRef.query;
        subtitle = Text(
          platformLabel,
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        );
      } else {
        title = cachedStats.name;
        final label = rankLabel(cachedStats);
        final rpText = '${formatNumber(cachedStats.rankScore)} RP';
        final rankAsset = rankAssetPath(cachedStats);

        subtitle = _RankSubtitle(
          platformLabel: platformLabel,
          rankText: label,
          rpText: rpText,
          rankAsset: rankAsset,
        );
      }
    } else {
      final byUid = playerRef.hasUid;
      final statsAsync = ref.watch(
        searchPlayerProvider((
          query: byUid ? playerRef.uid! : playerRef.query,
          platform: playerRef.platform,
          searchByUid: byUid,
        )),
      );
      final stats = statsAsync.whenOrNull(data: (result) => result.data);

      if (statsAsync.hasError) {
        leadingColor = AppTheme.red;
        title = playerRef.query;
        subtitle = const Text(
          'Failed to load',
          style: TextStyle(color: AppTheme.red, fontSize: 12),
        );
      } else if (stats == null) {
        leadingColor = AppTheme.muted;
        title = playerRef.query;
        subtitle = Text(
          platformLabel,
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        );
      } else {
        leadingColor = playerPresenceColor(stats);
        title = stats.name;
        final label = rankLabel(stats);
        final rpText = '${formatNumber(stats.rankScore)} RP';
        final rankAsset = rankAssetPath(stats);

        subtitle = _RankSubtitle(
          platformLabel: platformLabel,
          rankText: label,
          rpText: rpText,
          rankAsset: rankAsset,
        );
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: StatusDot(color: leadingColor),
      title: Text(title),
      subtitle: subtitle,
      onTap: onTap,
    );
  }

}

class _RankSubtitle extends StatelessWidget {
  final String platformLabel;
  final String rankText;
  final String rpText;
  final String rankAsset;

  const _RankSubtitle({
    required this.platformLabel,
    required this.rankText,
    required this.rpText,
    required this.rankAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          platformLabel,
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        const SizedBox(width: AppTheme.xs),
        const Text(
          '·',
          style: TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        const SizedBox(width: AppTheme.xs),
        SizedBox(
          width: 12,
          height: 12,
          child: Image.asset(
            rankAsset,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, trace) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: AppTheme.xs),
        Expanded(
          child: Text(
            '$rankText · $rpText',
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
