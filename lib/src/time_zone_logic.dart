import 'package:meta/meta.dart';

/// replace 'UTC' or 'GMT' to 'Z'
@internal
String replaceUtc(String formattedString) {
  final tzExp = _expressions.last;
  if (_hasTz(formattedString)) {
    final tz = tzExp.stringMatch(formattedString) ?? '+0000';
    final noTz = _removeTz(formattedString);

    return noTz + tz;
  }

  return formattedString;
}

String _removeTz(String timestamp) {
  var res = timestamp;
  for (final exp in _expressions) {
    res = res.replaceAllMapped(exp, (match) => ' ');
  }

  return res;
}

bool _hasTz(String timestamp) {
  for (final exp in _expressions) {
    if (exp.hasMatch(timestamp)) {
      return true;
    }
  }

  return false;
}

final _expressions = {
  // RegExp(r'\s*[\+]\d{2,4}', caseSensitive: false),
  RegExp(r'\s*utc', caseSensitive: false),
  RegExp(r'\s*gmt', caseSensitive: false),
  RegExp('Z', caseSensitive: false),
  RegExp(r'\s+[\+-]\d+', caseSensitive: false),
};