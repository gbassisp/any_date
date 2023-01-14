import 'package:any_date/src/extensions.dart';

import 'package:meta/meta.dart';

part 'any_date_rules.dart';
part 'any_date_rules_model.dart';

class DateParsingParameters {
  final String formattedString;
  final DateParserInfo parserInfo;

  DateParsingParameters({
    required this.formattedString,
    required this.parserInfo,
  });
}

class DateParserInfo {
  /// interpret the first value in an ambiguous case (e.g. 01/01/01)
  /// as day [true] or month [false].
  /// If yearFirst is to [true], this chooses between YDM and YMD.
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

  const DateParserInfo({
    this.dayFirst = false,
    this.yearFirst = false,
    this.allowedSeparators = const [' ', '/', '-'],
  });
}

/// main class, containing most [DateTime] utils
class AnyDate {
  /// settings for parsing and resolving ambiguous cases
  final DateParserInfo info;
  AnyDate({this.info = const DateParserInfo()});

  @visibleForTesting
  List<String> get allowedSeparators => info.allowedSeparators;

  /// parses a string in any format into a [DateTime] object.
  /// missing components will be assumed to default value:
  /// e.g. 'Jan 2023' becomes DateTime(2023, 1), which is 1 Jan 2023
  /// if year is missing, the closest result to today is chosen.
  DateTime parse(
    /// required string representation of a date to be parsed
    String formattedString, {

    /// overrides value on [DateParserInfo]
    bool? dayFirst,

    /// overrides value on [DateParserInfo]
    bool? yearFirst,
  }) {
    return tryParse(formattedString,
            dayFirst: dayFirst, yearFirst: yearFirst) ??
        _noValidFormatFound(formattedString);
  }

  /// parses a string in any format into a [DateTime] object.
  /// missing components will be assumed to default value:
  /// e.g. 'Jan 2023' becomes DateTime(2023, 1), which is 1 Jan 2023
  /// if year is missing, the closest result to today is chosen.
  DateTime? tryParse(
    /// required string representation of a date to be parsed
    String formattedString, {

    /// overrides value on [DateParserInfo]
    bool? dayFirst,

    /// overrides value on [DateParserInfo]
    bool? yearFirst,
  }) {
    final info = DateParserInfo(
      dayFirst: dayFirst ?? this.info.dayFirst,
      yearFirst: yearFirst ?? this.info.yearFirst,
    );

    formattedString = formattedString.trim().toLowerCase();

    return _applyRules(formattedString, info).firstWhere(
      (e) => e != null,
      orElse: () => null,
    );
    ;
  }

  // apply all rules
  Iterable<DateTime?> _applyRules(
    String formattedString,
    DateParserInfo info,
  ) sync* {
    final params = DateParsingParameters(
        formattedString: formattedString, parserInfo: info);

    // default rule from DateTime
    if (!info.dayFirst) {
      yield _dateTimeTryParse(formattedString);
    }

    // all MDY rules
    yield _mdy(formattedString, info, allowedSeparators);

    // all DMY rules
    yield _dmy(formattedString, info, allowedSeparators);

    if (info.dayFirst) {
      yield _ydm(formattedString, info, allowedSeparators);
      yield _ymd(formattedString, info, allowedSeparators);
    } else {
      yield _ymd(formattedString, info, allowedSeparators);
      yield _ydm(formattedString, info, allowedSeparators);
    }
    // finally force try parsing
  }
}
