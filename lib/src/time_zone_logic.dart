import 'package:meta/meta.dart';

// final _tzExp = RegExp(r'[\+\-]\d{2}\:?\d{0,2}\s*$');
final _tzExp = RegExp(r'\s*(\+\d{2}|-\d{2})(:?\d{2})?\s*$');

/// checks if timestamp has timezone offset, i.e.:
/// has timezone looking component && has time component (it doesn't make
/// sense to have tz without time component)
@internal
bool hasTimezoneOffset(String timestamp) {
  final tz = getTimezoneOffset(timestamp);

  return tz != null && _hasTimeComponent(timestamp);
}

/// removes timezone offset from string
@internal
String removeTimezoneOffset(String timestamp) {
  final tz = replaceUtc(timestamp).replaceAllMapped(_tzExp, (match) => '');

  return tz;
}

/// gets timezone offset if existing, else returns null
@internal
String? getTimezoneOffset(String timestamp) {
  final tz = _tzExp.stringMatch(replaceUtc(timestamp));

  return tz;
}

/// replace 'UTC' or 'GMT' to 'Z'
@internal
String replaceUtc(String formattedString) {
  if (_isUtc(formattedString)) {
    final tz = _tzExp.stringMatch(formattedString) ?? '+0000';
    final noTz = _removeTz(formattedString);

    return '$noTz $tz';
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

bool _isUtc(String timestamp) {
  for (final exp in _expressions) {
    if (exp.hasMatch(timestamp)) {
      return true;
    }
  }

  return false;
}

bool _hasTimeComponent(String timestamp) {
  final timeExp = RegExp(r'\d{1,2}:\d{1,2}');
  final time = timeExp.stringMatch(removeTimezoneOffset(timestamp));

  return time != null;
}

final _expressions = {
  // RegExp(r'\s*[\+]\d{2,4}', caseSensitive: false),
  RegExp(r'\s*utc', caseSensitive: false),
  RegExp(r'\s*gmt', caseSensitive: false),
  RegExp(r'\WZ\s*$', caseSensitive: false),
  // RegExp(r'\s*[\+-]\d{2}\:?\d{0,2}\s*$', caseSensitive: false),
  // RegExp(r'\s+[\+-]\d{2,4}'),
  // RegExp(r'[\+\-]\d{2}[\:\d{2}]?\s*$'),
  _tzExp,

  // // RegExp(r'\s+[\+-]\d+', caseSensitive: false),
  // RegExp(r'\s*[\+\-]\d{2}\:?\d{0,2}\s*$', caseSensitive: false),
};
