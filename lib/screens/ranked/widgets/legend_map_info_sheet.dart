import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

/// "What does this chart mean?" for the Legend × Map matrix.
void showLegendMapInfoSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusLg),
      ),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.8,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppTheme.md,
          AppTheme.md,
          AppTheme.md,
          AppTheme.lg,
        ),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.md),
          const Text(
            'Reading the Legend × Map Grid',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.lg),
          ..._section('What each cell shows', [
            'Every cell is one legend on one map, using only your ranked '
                'games in the current scope. The top number is how many '
                'games you played as that legend on that map.',
            'The bottom number is your average Ranked Points change per '
                'game for that pairing: green means that combination has '
                'gained RP on average, red means it has lost RP on average.',
          ]),
          const SizedBox(height: AppTheme.md),
          ..._section('Rows and columns', [
            'Legends and maps are both ordered by how often you played '
                'them, most-played first, so the pairings you rely on most '
                'are the easiest to find.',
          ]),
          const SizedBox(height: AppTheme.md),
          ..._section('Blank cells', [
            'A dash means you have no ranked games as that legend on that '
                'map in this scope, not that the pairing performed badly.',
          ]),
        ],
      ),
    ),
  );
}

List<Widget> _section(String title, List<String> paragraphs) {
  return [
    Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: AppTheme.sm),
    Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final p in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.sm),
              child: Text(
                p,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    ),
  ];
}
