import 'package:any_date/any_date.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:lean_extensions/dart_essentials.dart';
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
  /// returns the string parsed as an int or null
  int? tryToInt() => int.tryParse(trim());

  /// returns the string parsed as int
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

/// allows getting parser info from locale
@visibleForTesting
extension LocaleExtensions on Locale {
  static final _date = DateTime(1234, 5, 6, 7, 8, 9);

  String get _yMd => DateFormat.yMd(toString()).format(_date);

  /// returns the appropriate date parsing params for this locale
  DateParserInfo get parserInfo => DateParserInfo(
        yearFirst: usesYearFirst,
        dayFirst: !usesMonthFirst,
        months: [...longMonths, ...shortMonths],
        weekdays: [...longWeekdays, ...shortWeekdays],
        allowedSeparators: separators.toList(),
      );

  /// whether this locale uses 0-9 digits to represent numbers
  bool get usesNumericSymbols {
    try {
      usesMonthFirst;
      usesYearFirst;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// whether this locale uses month before day (e.g. US)
  bool get usesMonthFirst {
    final formatted = _yMd;
    final fields = formatted.split(RegExp(r'\D'))
      ..removeWhere((element) => element.trim().tryToInt() == null);
    final numbers = fields.map((e) => e.toInt());

    assert(
      numbers.contains(5),
      'could not find test date in $this: $formatted',
    );

    final monthIndex = numbers.indexOf(5);
    final dayIndex = numbers.indexOf(6);

    assert(
      monthIndex != null && dayIndex != null,
      'month and day must both be present in $this: $formatted',
    );
    return monthIndex! < dayIndex!;
  }

  /// whether this locale uses year before month and day (e.g. CH)
  bool get usesYearFirst {
    final formatted = _yMd;
    final fields = formatted.split(RegExp(r'\D'))
      ..removeWhere((element) => element.trim().tryToInt() == null);
    final numbers = fields.map((e) => e.toInt());

    assert(
      numbers.contains(1234),
      'could not find test date in $this: $formatted',
    );

    final yearIndex = numbers.indexOf(1234);
    final monthIndex = numbers.indexOf(5);

    assert(
      yearIndex != null && monthIndex != null,
      'month and year must both be present in $this: $formatted',
    );
    return yearIndex! < monthIndex!;
  }

  /// gets all months on long text form
  Iterable<Month> get longMonths sync* {
    final format = DateFormat('MMMM', toString());
    for (final i in range(12)) {
      final m = i + 1;
      final d = DateTime(1234, m, 10);
      yield Month(number: m, name: format.format(d));
    }
  }

  /// gets all months on short text form
  Iterable<Month> get shortMonths sync* {
    final format = DateFormat('MMM', toString());
    for (final i in range(12)) {
      final m = i + 1;
      final d = DateTime(1234, m, 10);
      yield Month(number: m, name: format.format(d));
    }

    yield* _nonNumericMonths;
  }

  /// returns months that would be represented by 0-9 digits in most languages
  Iterable<Month> get _nonNumericMonths sync* {
    final format = DateFormat('M', toString());
    for (final i in range(12)) {
      final m = i + 1;
      final d = DateTime(1234, m, 10);
      final name = format.format(d);
      // month is not represented by a number
      if (name.tryToInt() == null) {
        yield Month(number: m, name: name);
      }
    }
  }

  /// gets all weekdays on long text form
  Iterable<Weekday> get longWeekdays sync* {
    final format = DateFormat('EEEE', toString());
    for (final i in range(7)) {
      final w = i + 1;
      final d = DateTime(2023, 10, 8 + w);
      yield Weekday(number: w, name: format.format(d));
    }
  }

  /// gets all weekdays on short text form
  Iterable<Weekday> get shortWeekdays sync* {
    final format = DateFormat('EEE', toString());
    for (final i in range(7)) {
      final w = i + 1;
      final d = DateTime(2023, 10, 8 + w);
      yield Weekday(number: w, name: format.format(d));
    }
  }

  /// locale-specific separators, such as right-to-left mark
  static const _extraSeparators = [
    '\u200F',
  ];

  /// gets all weekdays on short text form
  Iterable<String> get separators sync* {
    final format = DateFormat.yMd(toLanguageTag());
    for (final i in range(12)) {
      final m = i + 1;
      final d = DateTime(1234, m, 10);
      final formatted = format.format(d);
      for (final sep in _extraSeparators) {
        if (formatted.contains(sep)) {
          yield sep;
        }
      }
    }
    yield* const DateParserInfo().allowedSeparators;
  }
}

extension _ListExtension<T> on Iterable<T> {
  int? indexOf(T element) {
    for (final i in range(length)) {
      if (elementAt(i) == element) {
        return i;
      }
    }

    return null;
  }
}
