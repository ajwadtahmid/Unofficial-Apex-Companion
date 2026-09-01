import 'package:flutter/material.dart';
import '../../utils/ranked/ranked_aggregates.dart';
import '../../utils/theme.dart';
import '../../widgets/surface_card.dart';
import 'widgets/ranked_day_of_week_chart.dart';
import 'widgets/ranked_time_of_day_chart.dart';

/// Entry point for the combined "when do I play best" screen: performance by
/// hour and by day-of-week together, out of the main Overview list so it
/// doesn't compete for space with the RP-focused cards there.
class RankedTimeBreakdownEntry extends StatelessWidget {
  final List<HourBucket> hourBuckets;
  final List<WeekdayBucket> weekdayBuckets;
  const RankedTimeBreakdownEntry({
    super.key,
    required this.hourBuckets,
    required this.weekdayBuckets,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RankedTimeBreakdownScreen(
              hourBuckets: hourBuckets,
              weekdayBuckets: weekdayBuckets,
            ),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppTheme.md),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 18, color: AppTheme.accent),
              SizedBox(width: AppTheme.sm),
              Expanded(
                child: Text(
                  'By Hour & Day',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen pairing of the hour-of-day and day-of-week charts. Both take
/// precomputed buckets, so this works unchanged at split or Lifetime scope.
class RankedTimeBreakdownScreen extends StatelessWidget {
  final List<HourBucket> hourBuckets;
  final List<WeekdayBucket> weekdayBuckets;
  const RankedTimeBreakdownScreen({
    super.key,
    required this.hourBuckets,
    required this.weekdayBuckets,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance by Time')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.md),
          children: [
            RankedTimeOfDayChart(buckets: hourBuckets),
            const SizedBox(height: AppTheme.md),
            RankedDayOfWeekChart(buckets: weekdayBuckets),
          ],
        ),
      ),
    );
  }
}
