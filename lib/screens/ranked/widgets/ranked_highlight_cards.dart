import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/legend_constants.dart';
import '../../../constants/ranked_map_constants.dart';
import '../../../models/player_stats.dart';
import '../../../models/ranked_match.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/formatting/format.dart'
    show formatNumber, formatDuration;
import '../../../utils/ranked/ranked_aggregates.dart';
import '../../../utils/storage/legend_stats_storage.dart';
import '../../../utils/theme.dart';
import '../../../widgets/legend_asset_image.dart';
import '../../../widgets/legend_detail_page.dart';
import '../../../widgets/stat_display.dart';
import '../../../widgets/surface_card.dart';
import '../../../widgets/win_loss_stat.dart';
import '../ranked_entity_history_screen.dart';
import 'map_rp_badge.dart';
import 'match_history_items.dart' show MatchGrouping;

/// Overview highlight reel: best & worst legends (one per line, tappable for a
/// detail sheet) and the worst & best maps (image banners, also tappable). Each
/// sheet's "View all history" button reuses [RankedEntityHistoryScreen] — the
/// same drill-down the Legends/Maps tabs push to. "Unknown" maps are excluded.
/// Takes precomputed breakdowns so it works off either the in-memory split
/// aggregates or the SQL lifetime aggregates; [legendMatchesFor]/
/// [mapMatchesFor] resolve one entity's matches lazily, same as those tabs.
class RankedOverviewHighlights extends StatelessWidget {
  final List<LegendBreakdown> legends;
  final List<MapBreakdown> maps;
  final Future<List<RankedMatch>> Function(String legend) legendMatchesFor;
  final Future<List<RankedMatch>> Function(String mapKey) mapMatchesFor;
  final Future<void> Function() onRefresh;

  const RankedOverviewHighlights({
    super.key,
    required this.legends,
    required this.maps,
    required this.legendMatchesFor,
    required this.mapMatchesFor,
    required this.onRefresh,
  });

  static String _signed(double v) =>
      '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}';

  @override
  Widget build(BuildContext context) {
    final legendsRanked = _rankByAvgRp(
      legends,
      (l) => l.games,
      (l) => l.avgRpPerGame,
    );
    final mapsRanked = _rankByAvgRp(
      maps.where((m) => !isUnknownMapKey(m.mapKey)).toList(),
      (m) => m.games,
      (m) => m.avgRpPerGame,
    );

    // Split legends into top (best) and bottom (worst) without overlap.
    final n = legendsRanked.length;
    final worstCount = n >= 2 ? (n >= 4 ? 2 : 1) : 0;
    final bestCount = (n - worstCount).clamp(0, 2);
    final best = legendsRanked.take(bestCount).toList();
    final worst = legendsRanked.sublist(n - worstCount).reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (best.isNotEmpty) ...[
          const _SectionLabel('Best Legends'),
          _legendList(best),
        ],
        if (worst.isNotEmpty) ...[
          const SizedBox(height: AppTheme.md),
          const _SectionLabel('Worst Legends'),
          _legendList(worst),
        ],
        if (mapsRanked.isNotEmpty) ...[
          const SizedBox(height: AppTheme.md),
          const _SectionLabel('Maps'),
          _MapHighlight(
            label: 'Best Map',
            map: mapsRanked.first,
            matchesFor: mapMatchesFor,
            onRefresh: onRefresh,
          ),
          if (mapsRanked.length > 1) ...[
            const SizedBox(height: AppTheme.sm),
            _MapHighlight(
              label: 'Worst Map',
              map: mapsRanked.last,
              matchesFor: mapMatchesFor,
              onRefresh: onRefresh,
            ),
          ],
        ],
      ],
    );
  }

  Widget _legendList(List<LegendBreakdown> items) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppTheme.sm),
          _CompactLegend(
            breakdown: items[i],
            matchesFor: legendMatchesFor,
            onRefresh: onRefresh,
          ),
        ],
      ],
    );
  }

  /// Ranks by average RP/game (desc), preferring items with enough games to be
  /// meaningful but falling back to all when too few qualify.
  static List<T> _rankByAvgRp<T>(
    List<T> all,
    int Function(T) games,
    double Function(T) avgRp,
  ) {
    final qualified = all
        .where((e) => games(e) >= kMinGamesForInsight)
        .toList();
    final pool = qualified.isNotEmpty ? qualified : List<T>.from(all);
    pool.sort((a, b) => avgRp(b).compareTo(avgRp(a)));
    return pool;
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sm, left: 2),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CompactLegend extends StatelessWidget {
  final LegendBreakdown breakdown;
  final Future<List<RankedMatch>> Function(String legend) matchesFor;
  final Future<void> Function() onRefresh;

  const _CompactLegend({
    required this.breakdown,
    required this.matchesFor,
    required this.onRefresh,
  });

  void _openDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => _LegendDetailSheet(
        breakdown: breakdown,
        matchesFor: matchesFor,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final positive = breakdown.avgRpPerGame >= 0;
    final rpColor = positive ? AppTheme.green : AppTheme.red;

    return SurfaceCard(
      padding: const EdgeInsets.all(AppTheme.sm + 2),
      onTap: () => _openDetail(context),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: SizedBox(
              width: 44,
              height: 44,
              child: LegendAssetImage(
                imageKey: legendImageKey(breakdown.legend),
                displayName: breakdown.legend,
                fallbackFontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  breakdown.legend,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${RankedOverviewHighlights._signed(breakdown.avgRpPerGame)} RP/game',
                  style: TextStyle(
                    color: rpColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${breakdown.games}g · ${breakdown.avgKills.toStringAsFixed(1)}K · ${formatNumber(breakdown.avgDamage.round())} dmg',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.muted),
        ],
      ),
    );
  }
}

/// Detail sheet for a Best/Worst Legend highlight: the full stat set the
/// Legends tab shows per row, plus a "View all history" button that resolves
/// this legend's matches and pushes the same [RankedEntityHistoryScreen]
/// drill-down the Legends tab uses. "All Trackers" resolves the persisted
/// career [LegendStat] for this legend — a pure read of what
/// [mergeLegendStats] already wrote during the normal My Stats flow, so
/// opening this never re-triggers that merge — and pushes the same
/// [LegendDetailPage] My Stats uses; hidden when no matching stat exists.
class _LegendDetailSheet extends ConsumerWidget {
  final LegendBreakdown breakdown;
  final Future<List<RankedMatch>> Function(String legend) matchesFor;
  final Future<void> Function() onRefresh;

  const _LegendDetailSheet({
    required this.breakdown,
    required this.matchesFor,
    required this.onRefresh,
  });

  Future<void> _viewHistory(BuildContext context) async {
    final games = await matchesFor(breakdown.legend)
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RankedEntityHistoryScreen(
          title: breakdown.legend,
          subtitle: '${breakdown.games} ranked games · '
              '${RankedOverviewHighlights._signed(breakdown.avgRpPerGame)} RP/game',
          matches: games,
          onRefresh: onRefresh,
          groupLabel: 'map',
          grouping: MatchGrouping(
            keyOf: (m) => m.mapKey,
            nameOf: (m) => rankedMapName(m.mapKey),
          ),
        ),
      ),
    );
  }

  void _viewTrackers(BuildContext context, LegendStat stat) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LegendDetailPage(legend: stat)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = kLegendsByName[breakdown.legend.toLowerCase()];
    final uid = ref.watch(playerSettingsProvider.select((s) => s.uid));
    final prefs = ref.watch(sharedPreferencesProvider);
    final target = breakdown.legend.toLowerCase();
    LegendStat? legendStat;
    for (final s in loadLegendStats(prefs, uid: uid)) {
      if (s.name.toLowerCase() == target) {
        legendStat = s;
        break;
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: LegendAssetImage(
                      imageKey: legendImageKey(breakdown.legend),
                      displayName: breakdown.legend,
                      fallbackFontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        breakdown.legend,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (info != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: info.role.color.withAlpha(35),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            info.role.displayName,
                            style: TextStyle(
                              color: info.role.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),
            Wrap(
              spacing: AppTheme.sm,
              runSpacing: AppTheme.sm,
              children: [
                StatDisplay(label: 'Games', value: '${breakdown.games}'),
                WinLossStat(wins: breakdown.wins, losses: breakdown.losses),
                StatDisplay(
                  label: 'Avg RP',
                  value: RankedOverviewHighlights._signed(breakdown.avgRpPerGame),
                ),
                StatDisplay(
                  label: 'Total RP',
                  value: RankedOverviewHighlights._signed(breakdown.totalRp.toDouble()),
                ),
                StatDisplay(
                  label: 'Avg Kills',
                  value: breakdown.avgKills.toStringAsFixed(1),
                ),
                StatDisplay(
                  label: 'Total Kills',
                  value: formatNumber(breakdown.totalKills),
                ),
                StatDisplay(
                  label: 'Avg Dmg',
                  value: formatNumber(breakdown.avgDamage.round()),
                ),
                StatDisplay(
                  label: 'Total Dmg',
                  value: formatNumber(breakdown.totalDamage),
                ),
                StatDisplay(
                  label: 'Avg Time',
                  value: formatDuration(breakdown.avgLengthSecs.round()),
                ),
                StatDisplay(
                  label: 'Total Time',
                  value: formatDuration(breakdown.totalLengthSecs),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),
            Row(
              children: [
                if (legendStat != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewTrackers(context, legendStat!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        side: const BorderSide(color: AppTheme.accent),
                      ),
                      icon: const Icon(Icons.bar_chart, size: 18),
                      label: const Text('All Trackers'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.sm),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _viewHistory(context),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('View all history'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapHighlight extends StatelessWidget {
  final String label;
  final MapBreakdown map;
  final Future<List<RankedMatch>> Function(String mapKey) matchesFor;
  final Future<void> Function() onRefresh;

  const _MapHighlight({
    required this.label,
    required this.map,
    required this.matchesFor,
    required this.onRefresh,
  });

  void _openDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => _MapDetailSheet(
        map: map,
        matchesFor: matchesFor,
        onRefresh: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final positive = map.avgRpPerGame >= 0;
    final accent = positive ? AppTheme.green : AppTheme.red;
    final asset = rankedMapAsset(map.mapKey);

    return SurfaceCard(
      padding: EdgeInsets.zero,
      clip: Clip.antiAlias,
      onTap: () => _openDetail(context),
      child: SizedBox(
        height: 118,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (asset != null)
              Image.asset(
                asset,
                fit: BoxFit.cover,
                cacheWidth: 800,
                errorBuilder: (_, _, _) => Container(color: AppTheme.surface2),
              )
            else
              Container(color: AppTheme.surface2),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppTheme.cardScrimStart, AppTheme.cardScrimEnd],
                ),
              ),
            ),
            const Positioned(
              bottom: AppTheme.sm,
              right: AppTheme.sm,
              child: Icon(Icons.chevron_right, size: 20, color: Colors.white70),
            ),
            // Total RP gained/lost, top-right (matches the Maps tab).
            Positioned(
              top: AppTheme.sm,
              right: AppTheme.sm,
              child: MapRpBadge(totalRp: map.totalRp, color: accent),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    map.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        _MapStat(
                          label: 'Avg RP',
                          value: RankedOverviewHighlights._signed(
                            map.avgRpPerGame,
                          ),
                          color: accent,
                        ),
                        _MapStat(
                          label: 'Kills',
                          value: map.avgKills.toStringAsFixed(1),
                        ),
                        _MapStat(
                          label: 'Dmg',
                          value: formatNumber(map.avgDamage.round()),
                        ),
                        _MapStat(label: 'Games', value: '${map.games}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail sheet for a Best/Worst Map highlight: the full stat set the Maps tab
/// shows per row, plus a "View all history" button that resolves this map's
/// matches and pushes the same [RankedEntityHistoryScreen] drill-down the Maps
/// tab uses.
class _MapDetailSheet extends StatelessWidget {
  final MapBreakdown map;
  final Future<List<RankedMatch>> Function(String mapKey) matchesFor;
  final Future<void> Function() onRefresh;

  const _MapDetailSheet({
    required this.map,
    required this.matchesFor,
    required this.onRefresh,
  });

  Future<void> _viewHistory(BuildContext context) async {
    final games = await matchesFor(map.mapKey)
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RankedEntityHistoryScreen(
          title: map.displayName,
          subtitle: '${map.games} ranked games · '
              '${RankedOverviewHighlights._signed(map.avgRpPerGame)} RP/game',
          matches: games,
          onRefresh: onRefresh,
          groupLabel: 'legend',
          grouping: MatchGrouping(keyOf: (m) => m.legend, nameOf: (m) => m.legend),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = rankedMapAsset(map.mapKey);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: SizedBox(
                    width: 72,
                    height: 44,
                    child: asset != null
                        ? Image.asset(
                            asset,
                            fit: BoxFit.cover,
                            cacheWidth: 400,
                            errorBuilder: (_, _, _) =>
                                Container(color: AppTheme.surface2),
                          )
                        : Container(color: AppTheme.surface2),
                  ),
                ),
                const SizedBox(width: AppTheme.sm),
                Text(
                  map.displayName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),
            Wrap(
              spacing: AppTheme.sm,
              runSpacing: AppTheme.sm,
              children: [
                StatDisplay(label: 'Games', value: '${map.games}'),
                WinLossStat(wins: map.wins, losses: map.losses),
                StatDisplay(
                  label: 'Avg RP',
                  value: RankedOverviewHighlights._signed(map.avgRpPerGame),
                ),
                StatDisplay(
                  label: 'Total RP',
                  value: RankedOverviewHighlights._signed(map.totalRp.toDouble()),
                ),
                StatDisplay(
                  label: 'Avg Kills',
                  value: map.avgKills.toStringAsFixed(1),
                ),
                StatDisplay(
                  label: 'Total Kills',
                  value: formatNumber(map.totalKills),
                ),
                StatDisplay(
                  label: 'Avg Dmg',
                  value: formatNumber(map.avgDamage.round()),
                ),
                StatDisplay(
                  label: 'Total Dmg',
                  value: formatNumber(map.totalDamage),
                ),
                StatDisplay(
                  label: 'Avg Time',
                  value: formatDuration(map.avgLengthSecs.round()),
                ),
                StatDisplay(
                  label: 'Total Time',
                  value: formatDuration(map.totalLengthSecs),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _viewHistory(context),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
                icon: const Icon(Icons.history, size: 18),
                label: const Text('View all history'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MapStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
