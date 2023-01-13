extension DateTimeExtension on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  DateTime get nextDay {
    final dateOnly = DateTime(year, month, day);
    final next = dateOnly.add(
      Duration(hours: 36),
    ); // avoid daylight savings, leap seconds, etc... issues

    return copyWith(year: next.year, month: next.month, day: next.day);
  }
}
