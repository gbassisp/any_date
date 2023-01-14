part of 'any_date_base.dart';

/// default parsing rule from dart core
DateTime? _dateTimeTryParse(String formattedString) =>
    DateTime.tryParse(formattedString);

/// if no values were found, throws format exception
DateTime _noValidFormatFound(String formattedString) {
  print('no valid format identified for date $formattedString');
  return DateTime.parse(formattedString);
}

///
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

final _DateParsingRule _ymd = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(r'(?<year>\d{1,4})'
      '$s'
      r'(?<month>\d{1,2})'
      '$s'
      r'(?<day>\d{1,2})');

  return _try(re, params.formattedString);
});

final _DateParsingRule _ydm = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(r'(?<year>\d{1,4})'
      '$s'
      r'(?<day>\d{1,2})'
      '$s'
      r'(?<month>\d{1,2})');

  return _try(re, params.formattedString);
});

DateTime? _dmy(
    String formattedString, DateParserInfo info, List<String> separators) {}

DateTime? _mdy(
    String formattedString, DateParserInfo info, List<String> separators) {}

String _separatorPattern(List<String> separators) =>
    '[${separators.reduce((v1, v2) => '$v1,$v2')}]';
