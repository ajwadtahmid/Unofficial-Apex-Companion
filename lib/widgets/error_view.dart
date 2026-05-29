import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Centred error view with an icon, message, and a single action button.
/// Used by stats, search, and any other full-screen error state.
class ErrorView extends StatelessWidget {
  final String message;

  /// Label for the action button (defaults to 'Retry').
  final String actionLabel;

  /// Icon shown above the message (defaults to [Icons.error_outline]).
  final IconData icon;

  final VoidCallback onAction;

  const ErrorView({
    super.key,
    required this.message,
    required this.onAction,
    this.actionLabel = 'Retry',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.red),
            const SizedBox(height: AppTheme.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: AppTheme.md),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
