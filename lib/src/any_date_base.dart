import 'package:any_date/src/any_date_rules.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/locale_based_rules.dart';
import 'package:any_date/src/nonsense_formats.dart';
import 'package:any_date/src/param_cleanup_rules.dart';
import 'package:intl/locale.dart';
import 'package:meta/meta.dart';

/// Parameters passed to the parser
///
/// This class is mutable in order to easily update it from one rule to another
/// adding and polishing information
@internal
class DateParsingParameters {
  /// default constructor
  DateParsingParameters({
    required this.formattedString,
    required this.parserInfo,
    required this.originalString,
    this.weekday,
    this.month,
    this.simplifiedString,
    this.timezoneOffset,
    this.timeComponent,
  });

  /// The date string to be parsed
  String formattedString;

  /// The date string to be parsed
  final String originalString;

  /// The parser info to be used - see it as a configuration
  DateParserInfo parserInfo;

  /// expected weekday found on the string
  Weekday? weekday;

  /// expected month found on the string
  Month? month;

  /// simplified string
  String? simplifiedString;

  /// indentified timezone offset
  String? timezoneOffset;

  /// identified time component
  Duration? timeComponent;

  /// copy with
  DateParsingParameters copyWith({
    String? formattedString,
    DateParserInfo? parserInfo,
    String? originalString,
    Weekday? weekday,
    Month? month,
    String? simplifiedString,
    String? timezoneOffset,
    Duration? timeComponent,
  }) {
    return DateParsingParameters(
      formattedString: formattedString ?? this.formattedString,
      parserInfo: parserInfo ?? this.parserInfo,
      originalString: originalString ?? this.originalString,
      weekday: weekday ?? this.weekday,
      month: month ?? this.month,
      simplifiedString: simplifiedString ?? this.simplifiedString,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      timeComponent: timeComponent ?? this.timeComponent,
    );
  }

  @override
  String toString() {
    return '''
DateParsingParameters(
 formattedString: $formattedString,
 parserInfo: $parserInfo,
 originalString: $originalString,
 weekday: $weekday,
 month: $month,
 simplifiedString: $simplifiedString,
 timeComponent: $timeComponent,
    )''';
  }
}

/// A month, with its number and name.
/// It seems far fetched to have this class, but it follows a similar
/// approach to the Python dateutil package, without relying on a list index.
/// See:
/// [https://dateutil.readthedocs.io/en/stable/_modules/dateutil/parser/_parser.html](https://dateutil.readthedocs.io/en/stable/_modules/dateutil/parser/_parser.html#parserinfo)
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

/// A weekday with its number and name Must match DateTime.weekday;
/// Reason for this is the same as for [Month]
@immutable
class Weekday {
  /// default constructor
  const Weekday({required this.number, required this.name});

  /// weekday number that matches DateTime.weekday
  final int number;

  /// weekday name
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

/// Configuration for the parser
class DateParserInfo {
  /// default constructor
  const DateParserInfo({
    bool? dayFirst,
    bool? yearFirst,
    List<String>? allowedSeparators,
    List<Month>? months,
    List<Weekday>? weekdays,
    Iterable<DateParsingFunction>? customRules,
  })  : dayFirst = dayFirst ?? false,
        yearFirst = yearFirst ?? false,
        allowedSeparators = allowedSeparators ?? _defaultSeparators,
        months = months ?? allMonths,
        weekdays = weekdays ?? allWeekdays,
        customRules = customRules ?? const [];

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
  final Iterable<DateParsingFunction> customRules;

  static const _default = DateParserInfo();

  /// copy with
  DateParserInfo copyWith({
    bool? dayFirst,
    bool? yearFirst,
    Iterable<String>? allowedSeparators,
    Iterable<Month>? months,
    Iterable<Weekday>? weekdays,
    Iterable<DateParsingFunction>? customRules,
  }) {
    return DateParserInfo(
      dayFirst: dayFirst ?? this.dayFirst,
      yearFirst: yearFirst ?? this.yearFirst,
      allowedSeparators: allowedSeparators?.toList() ?? this.allowedSeparators,
      months: months?.toList() ?? this.months,
      weekdays: weekdays?.toList() ?? this.weekdays,
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
  factory AnyDate.fromLocale(Object? locale) {
    if (locale is Locale) {
      return locale.anyDate;
    }

    final localeString = locale?.toString();
    if (localeString != null) {
      final parsedLocale = Locale.tryParse(localeString);
      if (parsedLocale != null) {
        return parsedLocale.anyDate;
      }
    }

    // TODO(gbassisp): add logging function to warn about invalid Locale
    return const AnyDate();
  }

  // static const _default = AnyDate(info: DateParserInfo._default);

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
    Object? timestamp,
  ) {
    DateTime? res;
    if (timestamp != null) {
      res = timestamp is DateTime ? timestamp : _tryParse(timestamp.toString());
    }
    if (res == null) {
      throw FormatException('Invalid date format', timestamp);
    }
    return res;
  }

  /// Tries to parse a string in any format into a [DateTime] object.
  ///
  /// Returns null if the string is not a valid date.
  ///
  /// Does not handle other exceptions.
  DateTime? tryParse(Object? timestamp) {
    try {
      return parse(timestamp);
    } on FormatException {
      return null;
    }
  }

  DateTime? _tryParse(String formattedString) {
    /* 
      TODO(gbassisp): allow the following:
        missing components will be assumed to default value:
        e.g. 'Jan 2023' becomes DateTime(2023, 1), which is 1 Jan 2023
        if year is missing, the closest result to today is chosen.
    */
    return _applyRules(formattedString).firstWhere(
      (e) => e != null,
      orElse: () => null,
    );
  }

  // apply all rules
  Iterable<DateTime?> _applyRules(
    String formattedString,
  ) sync* {
    final p = DateParsingParameters(
      formattedString: formattedString,
      parserInfo: info,
      originalString: formattedString,
    );
    const d = DateParserInfo._default;
    final p2 = p.copyWith(parserInfo: d);

    yield _entryPoint(info).apply(p);
    // TODO(gbassisp): refactor to avoid duplication
    yield _entryPoint(DateParserInfo._default).apply(p2);
  }
}

DateParsingRule _entryPoint(DateParserInfo i) {
  return MultipleRules([
    isoRule,
    basicSetup,
    rfcRules,
    cleanupRules,
    // custom rules are only applied after rfc rules
    MultipleRules.fromFunctions(i.customRules),
    nonsenseRules,
    ambiguousCase,
    MultipleRules(i.dayFirst ? _yearLastDayFirst : _yearLast),
    MultipleRules(i.dayFirst ? _dayFirst : _defaultRules),

    // default rule from DateTime
    if (!i.dayFirst) maybeDateTimeParse,
  ]);
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

// TODO(gbassisp): consolidate short and long months into a pattern that accepts
// any substring of the month name
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
  Month(number: 6, name: 'June'),
  Month(number: 7, name: 'July'),
  Month(number: 8, name: 'Aug'),
  Month(number: 9, name: 'Sep'),
  Month(number: 9, name: 'Sept'),
  Month(number: 10, name: 'Oct'),
  Month(number: 11, name: 'Nov'),
  Month(number: 12, name: 'Dec'),
];

/// internal base values for all months in english
@internal
const allMonths = [..._months, ..._shortMonths];

/// map of default months (english)
@internal
final monthsMap = {
  for (final m in allMonths) m.name: m.number,
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

/// internal base values for all weekdays in english
@internal
const allWeekdays = [..._weekdays, ..._shortWeekdays];

// TODO(gbassisp): avoid messing up regex with special chars
const _defaultSeparators = [
  ' ',
  't',
  'T',
  ':',
  '.',
  ',',
  '_',
  '/',
  '-',
];
