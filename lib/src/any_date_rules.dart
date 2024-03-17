// ignore_for_file: public_member_api_docs

import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/extensions.dart';

/// only these separators are known by the parser; others will be replaced
const usedSeparators = {'-', ' ', ':'};
const _longYearPattern = r'(?<year>\d{3,5})';
const _yearPattern = r'(?<year>\d+)';
const _ambiguousYearPattern = r'(?<year>\d{2})';
const _dayPattern = r'(?<day>\d{1,2})';
const _textMonthPattern = r'(?<month>\w+)';
const _monthPattern = r'(?<month>\d{1,2})';
// const _anyMonthPattern = r'(?<month>\d{1,2}|\w+)';
const _hourPattern = r'(?<hour>\d{1,2})';
const _minutePattern = r'(?<minute>\d{1,2})';
const _secondPattern = r'(?<second>\d{1,2})';
const _microsecondPattern = r'(?<microsecond>\d{1,6})';
final _separatorPattern = '[${usedSeparators.reduce((v1, v2) => '$v1,$v2')}]+';
final _s = _separatorPattern;
final _timeSep = _s; // ':';
final _hmPattern = '$_hourPattern$_timeSep$_minutePattern';
final _hmsPattern = '$_hmPattern$_timeSep$_secondPattern';
final _hmsMsPattern = '$_hmsPattern.$_microsecondPattern';
final _timePatterns = [
  _hmsMsPattern,
  _hmsPattern,
  _hmPattern,
  _hourPattern,
];

/// default parsing rule from dart core
DateTime? dateTimeTryParse(String formattedString) =>
    DateTime.tryParse(formattedString.toUpperCase().trim());

/// if no values were found, throws format exception
DateTime noValidFormatFound(String formattedString) {
  return DateTime.parse(formattedString.toUpperCase());
}

int _closest(List<int> list, int value) {
  var closest = list.first;
  var diff = (closest - value).abs();
  for (final item in list) {
    final newDiff = (item - value).abs();
    if (newDiff < diff) {
      closest = item;
      diff = newDiff;
    }
  }
  return closest;
}

int _parseYear(String yearString) {
  final year = int.parse(yearString);
  final now = DateTime.now();
  assert(
    yearString.length == 2,
    'expected double digit year, but got $yearString',
  );
  if (yearString.length == 2) {
    final c = now.year ~/ 100;
    final currentCentury = '$c$yearString'.toInt();
    final nextCentury = currentCentury + 100;
    final previousCentury = currentCentury - 100;
    return _closest(
      [currentCentury, nextCentury, previousCentury],
      now.year,
    );
  }
  assert(
    year > 1900,
    'expected year close to $now, but got $year from $yearString',
  );
  return year;
}

DateTime? _try(
  RegExp format,
  String formattedString, {
  bool shortYear = false,
}) {
  try {
    final now = DateTime(DateTime.now().year);
    final match = format.firstMatch(formattedString)!;
    var map = <String, dynamic>{};
    for (final n in match.groupNames) {
      map[n] = match.namedGroup(n);
    }
    if (shortYear) {
      map['year'] = _parseYear(map['year']!.toString());
    }
    map = _parseMap(map, formattedString);
    return now.copyWithJson(map);
  } catch (_) {}

  return null;
}

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
    map = _parseMap(map, formattedString, months: months);
    return now.copyWithJson(map);
  } catch (_) {}

  return null;
}

int _amTo24(int hour) {
  if (hour == 12) {
    return 0;
  }
  return hour;
}

int _pmTo24(int hour) {
  if (hour == 12) {
    return 12;
  }
  return hour + 12;
}

int _amPmTo24(int hour, String formattedString) {
  if (_isAm(formattedString)) {
    return _amTo24(hour);
  }
  if (_isPm(formattedString)) {
    return _pmTo24(hour);
  }
  return hour;
}

Map<String, dynamic> _parseMap(
  Map<String, dynamic> map,
  String formattedString, {
  List<Month> months = const [],
}) {
  if (months.isNotEmpty) {
    map['month'] = months
        .firstWhere((element) => element.name.toLowerCase() == map['month'])
        .number;
  }

  if (map.containsKey('hour')) {
    final hour = int.parse(map['hour']!.toString());
    map['hour'] = hour;
    if (_isAmPm(formattedString)) {
      map['hour'] = _amPmTo24(hour, formattedString);
    }
  }

  if (map.containsKey('second')) {
    final second = int.tryParse(map['second']!.toString());
    map['second'] = second;
  }
  if (map.containsKey('microsecond')) {
    assert(!map.containsKey('millisecond'), 'cannot have both ms and us $map');
    final ms = int.tryParse((map['microsecond'] as String).padRight(6, '0'));
    map['microsecond'] = ms;

    // split micro into milli and micro
    final milli = ms! ~/ 1000;
    final micro = ms % 1000;
    map['millisecond'] = milli;
    map['microsecond'] = micro;
  }
  return map;
}

final DateParsingRule ambiguousCase = SimpleRule((params) {
  final y = params.parserInfo.yearFirst;
  final d = params.parserInfo.dayFirst;

  final String base;
  if (y && d) {
    // non-sense ydm format
    base = '$_ambiguousYearPattern'
        '$_s'
        '$_dayPattern'
        '$_s'
        '$_monthPattern';
  } else if (y) {
    // ymd
    base = '$_ambiguousYearPattern'
        '$_s'
        '$_monthPattern'
        '$_s'
        '$_dayPattern';
  } else if (d) {
    // dmy
    base = '$_dayPattern'
        '$_s'
        '$_monthPattern'
        '$_s'
        '$_ambiguousYearPattern';
  } else {
    // mdy
    base = '$_monthPattern'
        '$_s'
        '$_dayPattern'
        '$_s'
        '$_ambiguousYearPattern';
  }

  // const negativeLookBehind = r'(?<!\d)';
  const negativeLookBehind = '^';
  const negativeLookAhead = r'(?!\d)';
  final b = '$negativeLookBehind$base$negativeLookAhead';
  DateTime? res;
  for (final timePattern in _timePatterns) {
    final re = RegExp(b + _s + timePattern);
    res = _try(re, params.formattedString, shortYear: true);
    if (res != null) {
      return res;
    }
  }
  return _try(RegExp(b), params.formattedString, shortYear: true);
});

final _thousand = BigInt.from(1000);
final _sLimit = BigInt.from(8640000000);
final _msLimit = _sLimit * _thousand;
final _usLimit = _msLimit * _thousand;
final _nsLimit = _usLimit * _thousand;
final DateParsingRule _unixTime = SimpleRule((params) {
  final timestamp = params.originalString.trim();
  final number = timestamp.tryToBigInt();
  if (number != null) {
    final abs = number.abs();
    if (abs <= _sLimit) {
      return DateTime.fromMillisecondsSinceEpoch((number * _thousand).toInt());
    } else if (abs <= _msLimit) {
      return DateTime.fromMillisecondsSinceEpoch(number.toInt());
    } else if (abs <= _usLimit) {
      return DateTime.fromMicrosecondsSinceEpoch(number.toInt());
    } else if (abs <= _nsLimit) {
      return DateTime.fromMicrosecondsSinceEpoch((number ~/ _thousand).toInt());
    }
  }
  return null;
});

final DateParsingRule rfcRules = MultipleRules([
  maybeDateTimeParse,
  _rfc1123,
  _unixTime,
]);

final DateParsingRule _rfc1123 = SimpleRule((params) {
  final formatted = replaceUtc(params.originalString).replaceAll(',', ' ');
  final regex = RegExp(
    r'^(\w{3})\s+(\d{1,2})\s+(\w{3,20})\s+(\d{4,5})\s+(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?(.+)$',
  );

  final match = regex.firstMatch(formatted);
  // print(match?.group(0));
  if (match == null) {
    return null;
  }

  final day = int.parse(match.group(2)!);
  final month = _monthToInt(match.group(3)!);
  final year = int.parse(match.group(4)!);
  final hour = int.parse(match.group(5)!);
  final minute = int.parse(match.group(6)!);
  final second = int.parse(match.group(7)!);
  final fraction = match.group(8); // Fractional seconds, if present
  final timeZoneOffset = match.group(9)!.trim();
  // print('$year $month $day $hour $minute $second $timeZoneOffset');

  var dateTime = DateTime(year, month, day, hour, minute, second);
  // print(dateTime);
  if (fraction != null) {
    final milliseconds = int.parse(fraction.padRight(3, '0').substring(0, 3));
    dateTime = dateTime.add(Duration(milliseconds: milliseconds));
  }

  return DateTime.parse('$dateTime$timeZoneOffset');
});

final DateParsingRule ymd = MultipleRules([
  // maybeDateTimeParse,
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
  final d = params.originalString;
  // final separators = params.parserInfo.allowedSeparators;
  // final s = separatorPattern(separators);

  // if starts with 4 digits followed by a separator, then it's probably a date

  if (d.startsWith(RegExp('$_longYearPattern$_s'))) {
    return dateTimeTryParse(d) ?? dateTimeTryParse(params.formattedString);
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
  if (formattedString.contains(RegExp(r'\d{1,2}\s?pm'))) {
    return true;
  }
  return false;
}

bool _isAm(String formattedString) {
  if (formattedString.contains(RegExp(r'\d{1,2}\s?am'))) {
    return true;
  }
  return false;
}

int _monthToInt(String month, [Map<String, int>? months]) {
  months ??= monthsMap;
  return months[month]!;
}
