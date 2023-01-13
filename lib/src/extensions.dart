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

  DateTime copyWithJson(Map<String, Object?> json) {
    final j = json.map((key, value) => MapEntry(key.toLowerCase(), value));
    print(json);
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
      Duration(hours: 36),
    ); // avoid daylight savings, leap seconds, etc... issues

    return copyWith(year: next.year, month: next.month, day: next.day);
  }
}

extension StringParsers on String {
  int? tryToInt() => int.tryParse(trim());
}
