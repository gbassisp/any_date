part of 'any_date_base.dart';

/// default parsing rule from dart core
DateTime? _dateTimeTryParse(String formattedString) =>
    DateTime.tryParse(formattedString);

/// if no values were found, throws format exception
DateTime _noValidFormatFound(String formattedString) {
  print('no valid format identified for date $formattedString');
  return DateTime.parse(formattedString);
}

DateTime? _try(RegExp format, String formattedString) {
  try {
    final now = DateTime(DateTime.now().year);
    final match = format.firstMatch(formattedString)!;
    final map = <String, dynamic>{};
    for (var n in match.groupNames) {
      map[n] = match.namedGroup(n);
    }
    return now.copyWithJson(map);
  } catch (_) {}

  return null;
}

DateTime? _ymd(String formattedString, DateParserInfo info) {
  final re = RegExp(r'(?<year>\d+)/(?<month>\d+)/(?<day>\d+)');

  return _try(re, formattedString);
}

DateTime? _ydm(String formattedString, DateParserInfo info) {}

DateTime? _dmy(String formattedString, DateParserInfo info) {}

DateTime? _mdy(String formattedString, DateParserInfo info) {}
