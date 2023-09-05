import 'package:any_date/src/any_date_rules.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:meta/meta.dart';

/// Parameters passed to the parser
class DateParsingParameters {
  /// default constructor
  const DateParsingParameters({
    required this.formattedString,
    required this.parserInfo,
  });

  /// The date string to be parsed
  final String formattedString;

  /// The parser info to be used - see it as a configuration
  final DateParserInfo parserInfo;

  /// copy with
  DateParsingParameters copyWith({
    String? formattedString,
    DateParserInfo? parserInfo,
  }) {
    return DateParsingParameters(
      formattedString: formattedString ?? this.formattedString,
      parserInfo: parserInfo ?? this.parserInfo,
    );
  }
}

/// A month, with its number and name. Used to support multiple languages
/// without adding another dependency.
class Month {
  /// default constructor
  const Month({required this.number, required this.name});

  /// month number
  final int number;

  /// month name
  final String name;
}

/// A weekday with its number and name. Used to support multiple languages
/// without adding another dependency.
///
/// Must match DateTime().weekday
class Weekday {
  /// default constructor
  const Weekday({required this.number, required this.name});

  /// month number
  final int number;

  /// month name
  final String name;
}

/// used on iso date spacing; can and will be replaced with space
const _specialSeparators = {'t', 'T'};

/// only these separators are known by the parser; others will be replaced
const usedSeparators = {'-', ' ', ':'};
const _knownSeparators = {...usedSeparators, ..._specialSeparators};

/// these are the separators used by the default DateTime.parse
String replaceSeparators(String formattedString, Iterable<String> separators) {
  var result = formattedString;
  final unknownSeparators = separators.toSet().difference(_knownSeparators);

  for (final sep in unknownSeparators) {
    result = result.replaceAll(sep, '-');
  }
  return _restoreMillisecons(result);
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

  /// copy with
  DateParserInfo copyWith({
    bool? dayFirst,
    bool? yearFirst,
    List<String>? allowedSeparators,
    List<Month>? months,
  }) {
    return DateParserInfo(
      dayFirst: dayFirst ?? this.dayFirst,
      yearFirst: yearFirst ?? this.yearFirst,
      allowedSeparators: allowedSeparators ?? this.allowedSeparators,
      months: months ?? this.months,
    );
  }
}

/// main class, containing most [DateTime] utils
class AnyDate {
  /// default constructor
  const AnyDate({this.info});

  /// settings for parsing and resolving ambiguous cases
  final DateParserInfo? info;

  DateParserInfo get _info => info ?? defaultSettings;

  /// static value for global setting
  static DateParserInfo defaultSettings = const DateParserInfo();

  /// list of allowed separators
  @visibleForTesting
  List<String> get allowedSeparators => _info.allowedSeparators;

  /// parses a string in any format into a [DateTime] object.
  /// missing components will be assumed to default value:
  /// e.g. 'Jan 2023' becomes DateTime(2023, 1), which is 1 Jan 2023
  /// if year is missing, the closest result to today is chosen.
  DateTime parse(
    /// required string representation of a date to be parsed
    String formattedString,
  ) {
    return tryParse(formattedString) ?? noValidFormatFound(formattedString);
  }

  /// parses a string in any format into a [DateTime] object.
  /// missing components will be assumed to default value:
  /// e.g. 'Jan 2023' becomes DateTime(2023, 1), which is 1 Jan 2023
  /// if year is missing, the closest result to today is chosen.
  DateTime? tryParse(String formattedString) {
    final caseInsensitive = replaceSeparators(
      formattedString.trim().toLowerCase(),
      allowedSeparators,
    );

    return _applyRules(caseInsensitive).firstWhere(
      (e) => e != null,
      orElse: () => null,
    );
  }

  // apply all rules
  Iterable<DateTime?> _applyRules(
    String formattedString,
  ) sync* {
    final info = _info.copyWith(
          allowedSeparators: usedSeparators.toList(),
        );
    final p = DateParsingParameters(
      formattedString: formattedString,
      parserInfo: info,
    );

    yield MultipleRules(info.dayFirst ? _yearLastDayFirst : _yearLast).apply(p);

    final r = MultipleRules(info.dayFirst ? _dayFirst : _defaultRules);
    yield r.apply(p);

    // default rule from DateTime
    if (!info.dayFirst) {
      yield dateTimeTryParse(formattedString);
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
  Month(number: 10, name: 'Oct'),
  Month(number: 11, name: 'Nov'),
  Month(number: 12, name: 'Dec'),
];

/// all months used for parsing
const allMonths = [..._months, ..._shortMonths];

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

/// all weekdays used for parsing
const allWeekdays = [..._weekdays, ..._shortWeekdays];
