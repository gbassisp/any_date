part 'any_date_rules.dart';

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

  const DateParserInfo({this.dayFirst = false, this.yearFirst = false});
}

/// main class, containing most [DateTime] utils
class AnyDate {
  final DateParserInfo info;
  AnyDate({this.info = const DateParserInfo()});

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
    final _info = DateParserInfo(
      dayFirst: dayFirst ?? info.dayFirst,
      yearFirst: yearFirst ?? info.yearFirst,
    );

    return _applyRules(formattedString, _info).firstWhere((e) => e != null)
        as DateTime;
  }

  // apply all rules
  Iterable<DateTime?> _applyRules(
    String formattedString,
    DateParserInfo info, {
    bool throwOnInvalid = true,
  }) sync* {
    // default rule from DateTime
    yield _dateTimeTryParse(formattedString);

    // all MDY rules
    yield _mdy(formattedString, info);

    // all DMY rules
    yield _dmy(formattedString, info);

    // all YMD rules
    yield _ymd(formattedString, info);

    // all YDM rules
    yield _ydm(formattedString, info);

    // finally force try parsing
    if (throwOnInvalid) {
      yield _noValidFormatFound(formattedString);
    }
  }
}
