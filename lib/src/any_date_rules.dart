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

///
DateTime? _tryTextMonth(
    RegExp format, String formattedString, List<Month> months) {
  try {
    final now = DateTime(DateTime.now().year);
    final match = format.firstMatch(formattedString)!;
    final map = <String, dynamic>{};
    for (var n in match.groupNames) {
      map[n] = match.namedGroup(n);
    }
    map['month'] = months
        .firstWhere((element) => element.name.toLowerCase() == map['month'])
        .number;
    return now.copyWithJson(map);
  } catch (_) {}

  return null;
}

final _DateParsingRule _ymd = _MultipleRules([
  _ymdhmsTextMonthRegex,
  _ymdTextMonthRegex,
  _ymdRegex,
]);

final _DateParsingRule _ydm = _MultipleRules([
  _ydmTextMonthRegex,
  _ydmRegex,
]);

final _DateParsingRule _dmy = _MultipleRules([
  _dmyTextMonthRegex,
  _dmyRegex,
]);

final _DateParsingRule _mdy = _MultipleRules([
  _mdyTextMonthRegex,
  _mdyRegex,
]);

_DateParsingRule _ymdhmsTextMonthRegex = _SimpleRule((params) {
  final separators = params.parserInfo.allowedSeparators;
  final s = _separatorPattern(separators);
  final hms = _hmsPattern(separators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<month>\w+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    '($hms)?'
    r'$'
    //
    ,
  );

  // print(re);

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

_DateParsingRule _ymdTextMonthRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<month>\w+)'
    '$s'
    r'(?<day>\d{1,2})'
    r'$'
    //
    ,
  );

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

final _DateParsingRule _ymdRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<month>\d{1,2})'
    '$s'
    r'(?<day>\d{1,2})'
    r'$'
    //
    ,
  );

  return _try(re, params.formattedString);
});

final _DateParsingRule _ydmRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\d{1,2})'
    r'$'
    //
    ,
  );

  return _try(re, params.formattedString);
});

_DateParsingRule _ydmTextMonthRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\w+)'
    r'$'
    //
    ,
  );

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

final _DateParsingRule _mdyRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<month>\d{1,2})'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<year>\d+)'
    r'$'
    //
    ,
  );

  return _try(re, params.formattedString);
});

_DateParsingRule _mdyTextMonthRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<month>\w+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<year>\d+)'
    r'$'
    //
    ,
  );

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

final _DateParsingRule _dmyRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\d{1,2})'
    '$s'
    r'(?<year>\d+)'
    r'$'
    //
    ,
  );

  return _try(re, params.formattedString);
});

_DateParsingRule _dmyTextMonthRegex = _SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\w+)'
    '$s'
    r'(?<year>\d+)'
    r'$'
    //
    ,
  );

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

String _separatorPattern(List<String> separators) =>
    '[${separators.reduce((v1, v2) => '$v1,$v2')}]+?';

String _hmsPattern(List<String> separators) {
  final s = _separatorPattern(separators);

  return r'(?<hour>\d{1,2})?'
          '$s'
          r'(?<minute>\d{1,2})?'
          '$s'
          r'(?<second>\d{1,2})?'

      //
      ;
}

bool isAmPm(String formattedDate) {
  final r = RegExp(r'\w+');
  for (var element in r.allMatches(formattedDate.toLowerCase())) {
    for (int i = 0; i < element.groupCount; i++) {
      var e = element.group(i);
      if (e!.contains('am') || e.contains('pm')) {
        return true;
      }
    }
  }
  return false;
}
