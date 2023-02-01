import 'any_date_base.dart';
import 'any_date_rules_model.dart';
import 'extensions.dart';

/// default parsing rule from dart core
DateTime? dateTimeTryParse(String formattedString) =>
    DateTime.tryParse(formattedString);

/// if no values were found, throws format exception
DateTime noValidFormatFound(String formattedString) {
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
    var map = <String, dynamic>{};
    for (var n in match.groupNames) {
      map[n] = match.namedGroup(n);
    }
    map = _parseMap(map, formattedString, months);
    return now.copyWithJson(map);
  } catch (_) {}

  return null;
}

Map<String, dynamic> _parseMap(
    Map<String, dynamic> map, String formattedString, List<Month> months) {
  // print(map);
  map['month'] = months
      .firstWhere((element) => element.name.toLowerCase() == map['month'])
      .number;

  if (map.containsKey('hour')) {
    int hour = int.parse(map['hour']!);
    hour = _isAmPm(formattedString) ? hour % 12 : hour;
    map['hour'] = _isPm(formattedString) ? hour + 12 : hour;
  }

  if (map.containsKey('second')) {
    double second = double.parse(map['second']!);
    // print(second);
    map['second'] = second.toInt();
    map['millisecond'] = (second - second.toInt()) * 1000;
    map['microsecond'] = (second - second.toInt()) * 1000000;
  }
  return map;
}

final DateParsingRule ymd = MultipleRules([
  ymdhmsTextMonthRegex,
  ymdhmTextMonthRegex,
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

DateParsingRule ymdhmsTextMonthRegex = SimpleRule((params) {
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
    '$hms'

    //
    ,
  );

  // print(re);

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

DateParsingRule ymdhmTextMonthRegex = SimpleRule((params) {
  final separators = params.parserInfo.allowedSeparators;
  final s = _separatorPattern(separators);
  final hm = _hmPattern(separators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<month>\w+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    '$hm'

    //
    ,
  );

  // print(re);

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

DateParsingRule ymdTextMonthRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<month>\w+)'
    '$s'
    r'(?<day>\d{1,2})'

    //
    ,
  );

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

final DateParsingRule ymdRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<month>\d{1,2})'
    '$s'
    r'(?<day>\d{1,2})'

    //
    ,
  );

  return _try(re, params.formattedString);
});

final DateParsingRule ydmRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\d{1,2})'

    //
    ,
  );

  return _try(re, params.formattedString);
});

DateParsingRule ydmTextMonthRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<year>\d+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\w+)'

    //
    ,
  );

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

final DateParsingRule mdyRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<month>\d{1,2})'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<year>\d+)'

    //
    ,
  );

  return _try(re, params.formattedString);
});

DateParsingRule mdyTextMonthRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<month>\w+)'
    '$s'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<year>\d+)'

    //
    ,
  );

  return _tryTextMonth(re, params.formattedString, params.parserInfo.months);
});

final DateParsingRule dmyRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\d{1,2})'
    '$s'
    r'(?<year>\d+)'

    //
    ,
  );

  return _try(re, params.formattedString);
});

DateParsingRule dmyTextMonthRegex = SimpleRule((params) {
  final s = _separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    r'^'
    r'(?<day>\d{1,2})'
    '$s'
    r'(?<month>\w+)'
    '$s'
    r'(?<year>\d+)'

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
          r'(?<second>\d{1,2}\.?\d*)?'

      //
      ;
}

String _hmPattern(List<String> separators) {
  final s = _separatorPattern(separators);

  return r'(?<hour>\d{1,2})?'
          '$s'
          r'(?<minute>\d{1,2})?'

      //
      ;
}

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
