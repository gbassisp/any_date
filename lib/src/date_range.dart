import 'package:any_date/src/extensions.dart';

/// A range between two DateTime objects.
/// Inspired by Flutter > Material > DateTimeRange class
class DateTimeRange {
  /// Start DateTime of this DateTimeRange.
  late final DateTime start;

  /// End DateTime of this DateTimeRange.
  late final DateTime end;

  /// Creates a range for the given start and end values. [end] must be later than [start]
  DateTimeRange({
    required DateTime start,
    required DateTime end,
  }) {
    assert(!start.isAfter(end));
    // if user passes wrong values in production code, they are corrected here
    if (start.isAfter(end)) {
      this.start = end;
      this.end = start;
    }
    // otherwise default to normal case
    else {
      this.start = start;
      this.end = end;
    }
  }

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [DateTime.difference] for more details.
  Duration get duration => end.difference(start);

  Iterable<DateTime> get days sync* {
    DateTime d = start;
    while (d.isAfter(end)) {
      yield d;
      d = d.nextDay;
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DateTimeRange &&
            other.runtimeType == runtimeType &&
            other.start == start &&
            other.end == end);
  }

  @override
  int get hashCode => Object.hashAll([start, end]);

  @override
  String toString() => '$start - $end';
}
