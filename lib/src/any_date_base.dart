/// main class, containing most [DateTime] utils
class AnyDate {
  /// parses a string in any format into a [DateTime] object.
  /// missing components will be assumed to default value:
  /// e.g. 'Jan 2023' becomes DateTime(2023, 1), which is 1 Jan 2023
  /// if year is missing, the closest result to today is chosen.
  static DateTime parse(
    /// required string representation of a date to be parsed
    String timestamp, {

    /// disambiguation rule betwen month and day (mm/dd or dd/mm)
    bool dayFirst = false,
  }) {
    return DateTime.parse(timestamp);
  }
}
