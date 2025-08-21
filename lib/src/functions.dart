import 'package:any_date/any_date.dart';

const _defaultParser = AnyDate();

/// Parses a date string into a DateTime object.
DateTime parseAnyDateTime(Object? timestamp, {Object? locale}) {
  if (locale != null) {
    final parser = AnyDate.fromLocale(locale);
    return parser.parse(timestamp);
  }

  return _defaultParser.parse(timestamp);
}

/// Try parsing a date string into a DateTime object.
DateTime? tryParseAnyDateTime(Object? timestamp, {Object? locale}) {
  if (locale != null) {
    final parser = AnyDate.fromLocale(locale);
    return parser.tryParse(timestamp);
  }

  return _defaultParser.tryParse(timestamp);
}
