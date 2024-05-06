import 'package:any_date/src/any_date_rules.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/nonsense_formats.dart';
import 'package:any_date/src/param_cleanup_rules.dart';
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
    )''';
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
    this.months = allMonths,
    this.weekdays = allWeekdays,
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

  /// copy with
  DateParserInfo copyWith({
    bool? dayFirst,
    bool? yearFirst,
    List<String>? allowedSeparators,
    List<Month>? months,
    List<Weekday>? weekdays,
  }) {
    return DateParserInfo(
      dayFirst: dayFirst ?? this.dayFirst,
      yearFirst: yearFirst ?? this.yearFirst,
      allowedSeparators: allowedSeparators ?? this.allowedSeparators,
      months: months ?? this.months,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  @override
  String toString() {
    return 'DateParserInfo(dayFirst: $dayFirst, yearFirst: $yearFirst, '
        'allowedSeparators: $allowedSeparators, months: $months, '
        'weekdays: $weekdays)';
  }
}

/// main class, containing most [DateTime] utils
class AnyDate {
  /// default constructor
  const AnyDate({DateParserInfo? info}) : _info = info;

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
    final p = DateParsingParameters(
      formattedString: formattedString,
      parserInfo: info,
      originalString: formattedString,
    );

    yield _entryPoint(info).apply(p);
  }
}

DateParsingRule _entryPoint(DateParserInfo i) {
  return MultipleRules([
    cleanupRules,
    rfcRules,
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
