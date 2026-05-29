import 'package:intl/intl.dart';

final _rpFormat = NumberFormat('#,###');

/// Formats an integer with comma-separated thousands (e.g., 1000 → '1,000').
String formatNumber(int number) => _rpFormat.format(number);

/// Returns a relative time string (e.g., '2h ago', '5m ago') based on elapsed time.
String timeAgo(DateTime timestamp) {
  final elapsed = DateTime.now().difference(timestamp);
  if (elapsed.isNegative) return 'just now';
  if (elapsed.inMinutes < 1) return 'just now';
  if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
  return '${elapsed.inDays}d ago';
}

/// Capitalizes the first character of a string (e.g., 'apex' → 'Apex').
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
