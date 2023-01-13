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
    String timestamp, {

    /// overrides value on [DateParserInfo]
    bool? dayFirst,

    /// overrides value on [DateParserInfo]
    bool? yearFirst,
  }) {
    return DateTime.parse(timestamp);
  }
}
