import 'dart:convert';

/// Decodes a JSON-encoded string array from SharedPreferences.
/// Returns an empty list on null input or parse failure.
List<String> parseStringList(String? raw) {
  try {
    final list = (raw != null ? jsonDecode(raw) as List? : null) ?? [];
    return list.whereType<String>().toList();
  } on FormatException {
    return [];
  }
}
