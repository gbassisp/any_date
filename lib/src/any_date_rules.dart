// ignore_for_file: public_member_api_docs

import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/extensions.dart';

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

/// uses DateTime.parse if start with yyyy - temporary solution until
/// package is complete
///
/// This is needed because yy-mm-dd is ambiguous and cannot be passed to
/// DateTime.parse every time
DateParsingRule maybeDateTimeParse = SimpleRule((params) {
  final d = params.formattedString;
  final separators = params.parserInfo.allowedSeparators;
  final s = separatorPattern(separators);

  // if starts with 4 digits followed by a separator, then it's probably a date

  if (d.startsWith(RegExp('\\d?\\d?\\d\\d\\d$s'))) {
    return dateTimeTryParse(d);
  }

  return null;
});

DateParsingRule ymdhmsTextMonthRegex = SimpleRule((params) {
  final separators = params.parserInfo.allowedSeparators;
  final s = separatorPattern(separators);
  final hms = hmsPattern(separators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(separators);
  final hm = hmPattern(separators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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
  final s = separatorPattern(params.parserInfo.allowedSeparators);
  final re = RegExp(
    '^'
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

String separatorPattern(List<String> separators) =>
    '[${separators.reduce((v1, v2) => '$v1,$v2')}]+?';

String hmsPattern(List<String> separators) {
  final s = separatorPattern(separators);

  return r'(?<hour>\d{1,2})?'
          '$s'
          r'(?<minute>\d{1,2})?'
          '$s'
          r'(?<second>\d{1,2}\.?\d*)?'

      //
      ;
}

String hmPattern(List<String> separators) {
  final s = separatorPattern(separators);

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
