import 'package:meta/meta.dart';

/// removes timezone offset from string
@internal
String removeTimezoneOffset(String timestamp) {
  final tzExp = _expressions.last;
  final tz = tzExp.stringMatch(replaceUtc(timestamp));

  return tz ?? timestamp;
}

/// gets timezone offset if existing, else returns null
@internal
String? getTimezoneOffset(String timestamp) {
  final tzExp = _expressions.last;
  final tz = tzExp.stringMatch(replaceUtc(timestamp));

  return tz;
}

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
  // RegExp(r'\s*[\+-]\d{2}\:?\d{0,2}\s*$', caseSensitive: false),
  RegExp(r'\s+[\+-]\d+', caseSensitive: false),
};
