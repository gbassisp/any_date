// ignore_for_file: public_member_api_docs

import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/extensions.dart';

const _yearPattern = r'(?<year>\d+)';
const _longYearPattern = r'(?<year>\d{3,5})';
const _dayPattern = r'(?<day>\d{1,2})';
const _textMonthPattern = r'(?<month>\w+)';
const _monthPattern = r'(?<month>\d{1,2})';
// const _anyMonthPattern = r'(?<month>\d{1,2}|\w+)';
const _hourPattern = r'(?<hour>\d{1,2})';
const _minutePattern = r'(?<minute>\d{1,2})';
const _secondPattern = r'(?<second>\d{1,2}\.?\d*)';
final _separatorPattern = '[${usedSeparators.reduce((v1, v2) => '$v1,$v2')}]+';
final _s = _separatorPattern;
final _timeSep = _s; // ':';
final _hmPattern = '$_hourPattern$_timeSep$_minutePattern';
final _hmsPattern = '$_hmPattern$_timeSep$_secondPattern';
final _timePatterns = [
  _hmsPattern,
  _hmPattern,
  _hourPattern,
];

/// default parsing rule from dart core
DateTime? dateTimeTryParse(String formattedString) =>
    DateTime.tryParse(formattedString.toUpperCase());

/// if no values were found, throws format exception
DateTime noValidFormatFound(String formattedString) {
  return DateTime.parse(formattedString.toUpperCase());
}

///
DateTime? _try(RegExp format, String formattedString) {
  try {
    final now = DateTime(DateTime.now().year);
    final match = format.firstMatch(formattedString)!;
    final map = <String, dynamic>{};
    for (final n in match.groupNames) {
      map[n] = match.namedGroup(n);
    }
    return now.copyWithJson(map);
  } catch (_) {}

  return null;
}

///
DateTime? _tryTextMonth(
  RegExp format,
  String formattedString,
  List<Month> months,
) {
  try {
    final now = DateTime(DateTime.now().year);
    final match = format.firstMatch(formattedString)!;
    var map = <String, dynamic>{};
    for (final n in match.groupNames) {
      map[n] = match.namedGroup(n);
    }
    map = _parseMap(map, formattedString, months);
    return now.copyWithJson(map);
  } catch (_) {}

  return null;
}

Map<String, dynamic> _parseMap(
  Map<String, dynamic> map,
  String formattedString,
  List<Month> months,
) {
  // print(map);
  map['month'] = months
      .firstWhere((element) => element.name.toLowerCase() == map['month'])
      .number;

  if (map.containsKey('hour')) {
    var hour = int.parse(map['hour']!.toString());
    hour = _isAmPm(formattedString) ? hour % 12 : hour;
    map['hour'] = _isPm(formattedString) ? hour + 12 : hour;
  }

  if (map.containsKey('second')) {
    final second = double.parse(map['second']!.toString());
    // print(second);
    map['second'] = second.toInt();
    map['millisecond'] = (second - second.toInt()) * 1000;
    map['microsecond'] = (second - second.toInt()) * 1000000;
  }
  return map;
}

final DateParsingRule ymd = MultipleRules([
  maybeDateTimeParse,
  ymdTextMonthRegex,
  ymdRegex,
]);

final DateParsingRule ydm = MultipleRules([
  ydmTextMonthRegex,
  ydmRegex,
]);

final DateParsingRule dmy = MultipleRules([
  dmyTextMonthRegex,
  dmyRegex,
]);

final DateParsingRule mdy = MultipleRules([
  mdyTextMonthRegex,
  mdyRegex,
]);

/// uses DateTime.parse if start with yyyy - temporary solution until
/// package is complete
///
/// This is needed because yy-mm-dd is ambiguous and cannot be passed to
/// DateTime.parse every time
DateParsingRule maybeDateTimeParse = SimpleRule((params) {
  final d = params.formattedString;
  // final separators = params.parserInfo.allowedSeparators;
  // final s = separatorPattern(separators);

  // if starts with 4 digits followed by a separator, then it's probably a date

  if (d.startsWith(RegExp('$_longYearPattern$_s'))) {
    return dateTimeTryParse(d);
  }

  return null;
});

DateParsingRule ymdTextMonthRegex = SimpleRule((params) {
  final base = '^'
      '$_yearPattern'
      '$_s'
      '$_textMonthPattern'
      '$_s'
      '$_dayPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _tryTextMonth(re, params.formattedString, params.parserInfo.months);
    if (res != null) {
      return res;
    }
  }
  return _tryTextMonth(
    RegExp(base),
    params.formattedString,
    params.parserInfo.months,
  );
});

final DateParsingRule ymdRegex = SimpleRule((params) {
  final base = '^'
      '$_yearPattern'
      '$_s'
      '$_monthPattern'
      '$_s'
      '$_dayPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _try(re, params.formattedString);
    if (res != null) {
      return res;
    }
  }
  return _try(
    RegExp(base),
    params.formattedString,
  );
});

final DateParsingRule ydmRegex = SimpleRule((params) {
  final base = '^'
      '$_yearPattern'
      '$_s'
      '$_dayPattern'
      '$_s'
      '$_monthPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _try(re, params.formattedString);
    if (res != null) {
      return res;
    }
  }
  return _try(
    RegExp(base),
    params.formattedString,
  );
});

DateParsingRule ydmTextMonthRegex = SimpleRule((params) {
  // final s = separatorPattern(params.parserInfo.allowedSeparators);
  final base = '^'
      '$_yearPattern'
      '$_s'
      '$_dayPattern'
      '$_s'
      '$_textMonthPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _tryTextMonth(re, params.formattedString, params.parserInfo.months);
    if (res != null) {
      return res;
    }
  }
  return _tryTextMonth(
    RegExp(base),
    params.formattedString,
    params.parserInfo.months,
  );
});

final DateParsingRule mdyRegex = SimpleRule((params) {
  final base = '^'
      '$_monthPattern'
      '$_s'
      '$_dayPattern'
      '$_s'
      '$_yearPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _try(re, params.formattedString);
    if (res != null) {
      return res;
    }
  }
  return _try(
    RegExp(base),
    params.formattedString,
  );
});

DateParsingRule mdyTextMonthRegex = SimpleRule((params) {
  // final s = separatorPattern(params.parserInfo.allowedSeparators);
  final base = '^'
      '$_textMonthPattern'
      '$_s'
      '$_dayPattern'
      '$_s'
      '$_yearPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _tryTextMonth(re, params.formattedString, params.parserInfo.months);
    if (res != null) {
      return res;
    }
  }
  return _tryTextMonth(
    RegExp(base),
    params.formattedString,
    params.parserInfo.months,
  );
});

final DateParsingRule dmyRegex = SimpleRule((params) {
  final base = '^'
      '$_dayPattern'
      '$_s'
      '$_monthPattern'
      '$_s'
      '$_yearPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _try(re, params.formattedString);
    if (res != null) {
      return res;
    }
  }
  return _try(
    RegExp(base),
    params.formattedString,
  );
});

DateParsingRule dmyTextMonthRegex = SimpleRule((params) {
  // final s = separatorPattern(params.parserInfo.allowedSeparators);
  final base = '^'
      '$_dayPattern'
      '$_s'
      '$_textMonthPattern'
      '$_s'
      '$_yearPattern';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(base + _s + timePattern);
    res = _tryTextMonth(re, params.formattedString, params.parserInfo.months);
    if (res != null) {
      return res;
    }
  }
  return _tryTextMonth(
    RegExp(base),
    params.formattedString,
    params.parserInfo.months,
  );
});

// String separatorPattern(List<String> separators) =>
//     '[${separators.reduce((v1, v2) => '$v1,$v2')}]+?';

// String hmsPattern(List<String> separators) {
//   // final s = separatorPattern(separators);

//   return '$_hourPattern'
//           '$s'
//           '$_minutePattern'
//           '$s'
//           '$_secondPattern'

//       //
//       ;
// }

// String hmPattern(List<String> separators) {
//   // final s = separatorPattern(separators);

//   return '$_hourPattern'
//           '$s'
//           '$_minutePattern'

//       //
//       ;
// }

bool _isAmPm(String formattedString) {
  return _isAm(formattedString) || _isPm(formattedString);
}

bool _isPm(String formattedString) {
  if (formattedString.contains('pm')) {
    // print('is pm');
    return true;
  }
  return false;
}

bool _isAm(String formattedString) {
  if (formattedString.contains('am')) {
    // print('is am');
    return true;
  }
  return false;
}
