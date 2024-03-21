import 'package:any_date/src/any_date_rules.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/locale_based_rules.dart';
import 'package:intl/locale.dart';
import 'package:meta/meta.dart';

/// Parameters passed to the parser
class DateParsingParameters {
  /// default constructor
  const DateParsingParameters({
    required this.formattedString,
    required this.parserInfo,
    required this.originalString,
    this.weekday,
    this.month,
    this.simplifiedString,
  });

  /// The date string to be parsed
  final String formattedString;

  /// The date string to be parsed
  final String originalString;

  /// The parser info to be used - see it as a configuration
  final DateParserInfo parserInfo;

  /// expected weekday found on the string
  final Weekday? weekday;

  /// expected month found on the string
  final Month? month;

  /// simplified string
  final String? simplifiedString;

  /// copy with
  DateParsingParameters copyWith({
    String? formattedString,
    DateParserInfo? parserInfo,
    String? originalString,
    Weekday? weekday,
    Month? month,
    String? simplifiedString,
  }) {
    return DateParsingParameters(
      formattedString: formattedString ?? this.formattedString,
      parserInfo: parserInfo ?? this.parserInfo,
      originalString: originalString ?? this.originalString,
      weekday: weekday ?? this.weekday,
      month: month ?? this.month,
      simplifiedString: simplifiedString ?? this.simplifiedString,
    );
  }
}

/// A month, with its number and name. Used to support multiple languages
/// without adding another dependency.
///
/// It seems far fetched to have this class here, but it follows a similar
/// approach to the Python dateutil package. See:
/// https://dateutil.readthedocs.io/en/stable/_modules/dateutil/parser/_parser.html#parserinfo
@immutable
class Month {
  /// default constructor
  const Month({required this.number, required this.name});

  /// month number
  final int number;

  /// month name
  final String name;

  @override
  String toString() => 'Month($number, $name)';

  @override
  int get hashCode => number.hashCode ^ name.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Month && number == other.number && name == other.name;
  }
}

/// A weekday with its number and name. Used to support multiple languages
/// without adding another dependency.
///
/// Must match DateTime().weekday
///
/// Reason for this is the same as for [Month]
@immutable
class Weekday {
  /// default constructor
  const Weekday({required this.number, required this.name});

  /// month number
  final int number;

  /// month name
  final String name;

  @override
  String toString() => 'Weekday($number, $name)';

  @override
  int get hashCode => number.hashCode ^ name.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Weekday && number == other.number && name == other.name;
  }
}

/// used on iso date spacing; can and will be replaced with space
const _specialSeparators = {'t', 'T'};

const _usedSeparators = usedSeparators;
const _knownSeparators = {..._usedSeparators, ..._specialSeparators};

/// these are the separators used by the default DateTime.parse
String _replaceSeparators(String formattedString, Iterable<String> separators) {
  var result = formattedString;
  result = replaceUtc(result);
  final unknownSeparators = separators.toSet().difference(_knownSeparators);

  for (final sep in unknownSeparators) {
    result = result.replaceAll(sep, '-');
  }

  return _restoreMillisecons(result);
}

/// replace 'UTC' or 'GMT' to 'Z'
@internal
String replaceUtc(String formattedString) {
  return formattedString
      .replaceAllMapped(RegExp(r'\s*utc', caseSensitive: false), (match) => 'Z')
      .replaceAllMapped(
        RegExp(r'\s*gmt', caseSensitive: false),
        (match) => 'Z',
      );
}

String _restoreMillisecons(String formattedString) {
  // regex with T00:00:00-000
  final r = RegExp(r'[t,T]?(\d{2}:\d{2}:\d{2})-(\d+)');

  // replace with 00:00:00.000
  return formattedString.replaceAllMapped(
    r,
    (m) => ' ${m.group(1)}.${m.group(2)}',
  );
}

Month? _expectMonth(DateParsingParameters parameters) {
  final timestamp = parameters.formattedString.toLowerCase();
  final month = _allMonths.where(
    (element) => timestamp.contains(element.name.toLowerCase()),
  );

  if (month.isEmpty) {
    return null;
  }

  return month.first;
}

Weekday? _expectWeekday(DateParsingParameters parameters) {
  final timestamp = parameters.formattedString.toLowerCase();
  final weekday = _allWeekdays.where(
    (element) => timestamp.contains(element.name.toLowerCase()),
  );

  if (weekday.isEmpty) {
    return null;
  }

  return weekday.first;
}
// TODO(gbassisp): consolidate all these extra pre-processing functions

String _removeWeekday(DateParsingParameters parameters) {
  var formattedString = parameters.formattedString.toLowerCase();
  for (final w in _allWeekdays) {
    formattedString = formattedString.replaceAll(w.name.toLowerCase(), '');
  }

  return _removeExcessiveSeparators(
    parameters.copyWith(formattedString: formattedString),
  );
  // if (parameters.formattedString != formattedString) {
  //   print('removed weekday: ${parameters.formattedString} '
  //       '-> $formattedString');
  // }
  // return formattedString;
}

String _removeExcessiveSeparators(DateParsingParameters parameters) {
  var formattedString = parameters.formattedString;
  final separators = parameters.parserInfo.allowedSeparators;
  formattedString = _replaceSeparators(formattedString, separators);
  for (final sep in separators) {
    // replace multiple separators with a single one
    formattedString = formattedString.replaceAll(RegExp('[$sep]+'), sep);
  }

  return _trimSeparators(formattedString, separators);
}

String _trimSeparators(String formattedString, Iterable<String> separators) {
  var result = formattedString;
  for (final sep in separators) {
    while (result.startsWith(sep)) {
      result = result.substring(1).trim();
    }

    while (result.endsWith(sep)) {
      result = result.substring(0, result.length - 1).trim();
    }
  }
  return result;
}

/// Configuration for the parser
class DateParserInfo {
  /// default constructor
  const DateParserInfo({
    this.dayFirst = false,
    this.yearFirst = false,
    // TODO(gbassisp): avoid messing up regex with special chars
    this.allowedSeparators = const [
      ' ',
      't',
      'T',
      ':',
      '.',
      ',',
      '_',
      '/',
      '-',
    ],
    this.months = _allMonths,
    this.weekdays = _allWeekdays,
    this.customRules = const [],
  });

  /// interpret the first value in an ambiguous case (e.g. 01/01/01)
  /// as day true or month false.
  /// If yearFirst is to true, this chooses between YDM and YMD.
  ///
  /// Defaults to false.
  final bool dayFirst;

  /// interpret the first value in an ambiguous case (e.g. 01/01/01) as year.
  /// If true, the first ambiguous number is taken to be the year,
  /// otherwise the last ambiguous number is taken.
  ///
  /// Defaults to false.
  final bool yearFirst;

  /// separators used when parsing the date string
  final List<String> allowedSeparators;

  /// keywords to identify months (to support multiple languages)
  final List<Month> months;

  /// keywords to identify weekdays (to support multiple languages)
  final List<Weekday> weekdays;

  /// allow passing extra rules to parse the timestamp
  final Iterable<DateParsingRule> customRules;

  /// copy with
  DateParserInfo copyWith({
    bool? dayFirst,
    bool? yearFirst,
    List<String>? allowedSeparators,
    List<Month>? months,
    List<Weekday>? weekdays,
    Iterable<DateParsingRule>? customRules,
  }) {
    return DateParserInfo(
      dayFirst: dayFirst ?? this.dayFirst,
      yearFirst: yearFirst ?? this.yearFirst,
      allowedSeparators: allowedSeparators ?? this.allowedSeparators,
      months: months ?? this.months,
      weekdays: weekdays ?? this.weekdays,
      customRules: customRules ?? this.customRules,
    );
  }

  @override
  String toString() {
    return 'DateParserInfo(dayFirst: $dayFirst, yearFirst: $yearFirst, '
        'allowedSeparators: $allowedSeparators, months: $months, '
        'weekdays: $weekdays, customRules: $customRules)';
  }
}

/// main class, containing most [DateTime] utils
class AnyDate {
  /// default constructor
  const AnyDate({DateParserInfo? info}) : _info = info;

  /// factory constructor to create an [AnyDate] obj based on [locale]
  factory AnyDate.fromLocale(Locale locale) {
    return locale.anyDate;
  }

  /// settings for parsing and resolving ambiguous cases
  // final DateParserInfo? info;

  final DateParserInfo? _info;

  /// resolved info being used
  DateParserInfo get info => _info ?? defaultSettings;

  /// static value for global setting
  static DateParserInfo defaultSettings = const DateParserInfo();

  /// parses a string in any format into a [DateTime] object.
  DateTime parse(
    /// required string representation of a date to be parsed
    Object? formattedString,
  ) {
    DateTime? res;
    if (formattedString != null) {
      res = formattedString is DateTime
          ? formattedString
          : _tryParse(formattedString.toString());
    }
    if (res == null) {
      throw FormatException('Invalid date format', formattedString);
    }
    return res;
  }

  /// Tries to parse a string in any format into a [DateTime] object.
  ///
  /// Returns null if the string is not a valid date.
  ///
  /// Does not handle other exceptions.
  DateTime? tryParse(Object? formattedString) {
    try {
      return parse(formattedString);
    } on FormatException {
      return null;
    }
  }

  DateTime? _tryParse(String formattedString) {
    // TODO(gbassip): allow the following:
    // missing components will be assumed to default value:
    // e.g. 'Jan 2023' becomes DateTime(2023, 1), which is 1 Jan 2023
    // if year is missing, the closest result to today is chosen.

    return _applyRules(formattedString).firstWhere(
      (e) => e != null,
      orElse: () => null,
    );
  }

  // apply all rules
  Iterable<DateTime?> _applyRules(
    String formattedString,
  ) sync* {
    final caseInsensitive = _replaceSeparators(
      formattedString.trim().toLowerCase(),
      info.allowedSeparators,
    );
    final i = info.copyWith(
      allowedSeparators: _usedSeparators.toList(),
    );
    var p = DateParsingParameters(
      formattedString: caseInsensitive,
      parserInfo: i,
      originalString: formattedString,
    );

    p = p.copyWith(
      weekday: _expectWeekday(p),
      month: _expectMonth(p),
      simplifiedString: _removeWeekday(p),
    );

    yield rfcRules.apply(p);
    // custom rules are only applied after rfc rules
    // TODO(gbassisp): maybe custom rules to run before custom rules
    yield MultipleRules(i.customRules.toList()).apply(p);

    yield ambiguousCase.apply(p);
    yield MultipleRules(i.dayFirst ? _yearLastDayFirst : _yearLast).apply(p);

    final r = MultipleRules(i.dayFirst ? _dayFirst : _defaultRules);
    yield r.apply(p);

    // default rule from DateTime
    if (!i.dayFirst) {
      yield maybeDateTimeParse.apply(p);
    }
  }
}

final List<DateParsingRule> _yearLast = [
  mdy,
  dmy,
];

final List<DateParsingRule> _yearLastDayFirst = _yearLast.reversed.toList();

final List<DateParsingRule> _defaultRules = [
  ymd,
  ydm,
];

final List<DateParsingRule> _dayFirst = [
  ydm,
  ymd,
];

const _months = [
  Month(number: 1, name: 'January'),
  Month(number: 2, name: 'February'),
  Month(number: 3, name: 'March'),
  Month(number: 4, name: 'April'),
  Month(number: 5, name: 'May'),
  Month(number: 6, name: 'June'),
  Month(number: 7, name: 'July'),
  Month(number: 8, name: 'August'),
  Month(number: 9, name: 'September'),
  Month(number: 10, name: 'October'),
  Month(number: 11, name: 'November'),
  Month(number: 12, name: 'December'),
];

const _shortMonths = [
  Month(number: 1, name: 'Jan'),
  Month(number: 2, name: 'Feb'),
  Month(number: 3, name: 'Mar'),
  Month(number: 4, name: 'Apr'),
  Month(number: 5, name: 'May'),
  Month(number: 6, name: 'Jun'),
  Month(number: 7, name: 'Jul'),
  Month(number: 8, name: 'Aug'),
  Month(number: 9, name: 'Sep'),
  Month(number: 9, name: 'Sept'),
  Month(number: 10, name: 'Oct'),
  Month(number: 11, name: 'Nov'),
  Month(number: 12, name: 'Dec'),
];

const _allMonths = [..._months, ..._shortMonths];

/// map of default months (english)
@internal
final monthsMap = {
  for (final m in _allMonths) m.name: m.number,
};

const _weekdays = [
  Weekday(number: 1, name: 'Monday'),
  Weekday(number: 2, name: 'Tuesday'),
  Weekday(number: 3, name: 'Wednesday'),
  Weekday(number: 4, name: 'Thursday'),
  Weekday(number: 5, name: 'Friday'),
  Weekday(number: 6, name: 'Saturday'),
  Weekday(number: 7, name: 'Sunday'),
];

const _shortWeekdays = [
  Weekday(number: 1, name: 'Mon'),
  Weekday(number: 2, name: 'Tue'),
  Weekday(number: 3, name: 'Wed'),
  Weekday(number: 4, name: 'Thu'),
  Weekday(number: 5, name: 'Fri'),
  Weekday(number: 6, name: 'Sat'),
  Weekday(number: 7, name: 'Sun'),
];

const _allWeekdays = [..._weekdays, ..._shortWeekdays];
