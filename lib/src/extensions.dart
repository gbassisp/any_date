extension DateTimeExtension on DateTime {
  DateTime copyWith(
      {int? year,
      int? month,
      int? day,
      int? hour,
      int? minute,
      int? second,
      int? millisecond,
      int? microsecond,
      bool allowRollover = false,}) {
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

    if (!allowRollover &&
        month > 0 &&
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
        microsecond < 1000 &&

        // DateTime constructor accepts any int and rolls over values (e.g. 13 months = 1y1mo)
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

  DateTime copyWithJson(Map<String, Object?> json) {
    final j = json.map((key, value) => MapEntry(key.toLowerCase(), value));

    return copyWith(
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

  DateTime get nextDay {
    final dateOnly = DateTime(year, month, day);
    final next = dateOnly.add(
      const Duration(hours: 36),
    ); // avoid daylight savings, leap seconds, etc... issues

    return copyWith(
      year: next.year,
      month: next.month,
      day: next.day,
      allowRollover: true,
    );
  }
}

extension StringParsers on String {
  int? tryToInt() => int.tryParse(trim());
}
