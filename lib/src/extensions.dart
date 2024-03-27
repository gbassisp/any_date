import 'package:any_date/any_date.dart';
import 'package:meta/meta.dart';

/// a collection of extensions on [DateTime]
extension DateTimeExtension on DateTime {
  /// returns a copy of this DateTime with the given values
  DateTime safeCopyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
    bool allowRollover = false,
  }) {
    year ??= this.year;
    month ??= this.month;
    day ??= this.day;
    hour ??= this.hour;
    minute ??= this.minute;
    second ??= this.second;
    millisecond ??= this.millisecond;
    microsecond ??= this.microsecond;

    final copied = DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );

    if (
        // rollover is not allowed
        !allowRollover
            // and any value is out of range
            &&
            !(month > 0 &&
                month <= 12 &&
                day > 0 &&
                day <= 31 &&
                hour >= 0 &&
                hour < 24 &&
                minute >= 0 &&
                minute < 60 &&
                second >= 0 &&
                second < 60 &&
                millisecond >= 0 &&
                millisecond < 1000 &&
                microsecond >= 0 &&
                microsecond < 1000)

            // and the resulting value is different than the original
            &&
            !(copied.year == year &&
                copied.month == month &&
                copied.day == day &&
                copied.hour == hour &&
                copied.minute == minute &&
                copied.second == second &&
                copied.millisecond == millisecond &&
                copied.microsecond == microsecond)) {
      throw FormatException('invalid date time $copied');
    }

    return copied;
  }

  /// returns a copy of this DateTime with the given values by passing a json
  DateTime copyWithJson(Map<String, Object?> json) {
    final j = json.map((key, value) => MapEntry(key.toLowerCase(), value));

    return safeCopyWith(
      // allowRollover: false,
      year: '${j['year']}'.tryToInt(),
      month: '${j['month']}'.tryToInt(),
      day: '${j['day']}'.tryToInt(),
      hour: '${j['hour']}'.tryToInt(),
      minute: '${j['minute']}'.tryToInt(),
      second: '${j['second']}'.tryToInt(),
      millisecond: '${j['millisecond']}'.tryToInt(),
      microsecond: '${j['microsecond']}'.tryToInt(),
    );
  }

  /// returns the next day
  DateTime get nextDay {
    final dateOnly = DateTime(year, month, day);
    final next = dateOnly.add(
      const Duration(hours: 36),
    ); // avoid daylight savings, leap seconds, etc... issues

    return safeCopyWith(
      year: next.year,
      month: next.month,
      day: next.day,
      allowRollover: true,
    );
  }
}

const _parser = AnyDate();

/// a collection of extensions on [String]
extension StringParsers on String {
  /// return the string parsed as a BigInt or null
  BigInt? tryToBigInt() => BigInt.tryParse(trim());

  /// returns the string parsed as an int or null
  int? tryToInt() => int.tryParse(trim());

  /// returns the string parsed as an int or throw
  int toInt() => int.parse(trim());

  /// parses the string as a DateTime
  DateTime? tryToDateTime({bool utc = false}) {
    try {
      return toDateTime(utc: utc);
    } catch (_) {
      return null;
    }
  }

  /// parses the string as a DateTime
  DateTime toDateTime({bool utc = false}) {
    final res = _parser.parse(this);
    if (utc) {
      return res.toUtc();
    }
    return res;
  }
}

/// simple implementation of python-like iterator
@internal
Iterable<int> range(int size) sync* {
  for (var i = 0; i < size; i++) {
    yield i;
  }
}
