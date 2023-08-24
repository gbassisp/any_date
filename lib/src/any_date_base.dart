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

/// Configuration for the parser
class DateParserInfo {
  /// default constructor
  const DateParserInfo({
    this.dayFirst = false,
    this.yearFirst = false,
    // TODO(gbassip): avoid messing up regex with special chars
    this.allowedSeparators = const [
      ' ',
      't',
      'T',
      ':',
      ',',
      '_',
      '/',
      '-',
    ],
    this.months = _allMonths,
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
}

/// main class, containing most [DateTime] utils
class AnyDate {
  /// default constructor
  const AnyDate({this.info = const DateParserInfo()});

  /// settings for parsing and resolving ambiguous cases
  final DateParserInfo info;

  /// list of allowed separators
  @visibleForTesting
  List<String> get allowedSeparators => info.allowedSeparators;

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
    final caseInsensitive = formattedString.trim().toLowerCase();

    return _applyRules(caseInsensitive).firstWhere(
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
    );

    yield MultipleRules([
      mdy,
      dmy,
    ]).apply(p);

    final r = MultipleRules(info.dayFirst ? _dayFirst : _defaultRules);
    yield r.apply(p);

    // default rule from DateTime
    if (!info.dayFirst) {
      yield dateTimeTryParse(formattedString);
    }
  }
}

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

const _allMonths = [..._months, ..._shortMonths];
