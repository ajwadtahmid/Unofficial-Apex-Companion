import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'surface_card.dart';

/// A unified error widget.
///
/// [compact] = false → full-width inline block with icon, message, and retry button.
/// [compact] = true  → summary-tile style row with icon, title/subtitle, and retry button.
class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.md,
            vertical: AppTheme.summaryTileVerticalPadding,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: AppTheme.orange,
                size: 22,
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'Failed to load',
                      style: TextStyle(color: AppTheme.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: AppTheme.accent, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return SurfaceCard(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.orange,
            size: 32,
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppTheme.accent),
              ),
            ),
        ],
      ),
    );
  }
}
