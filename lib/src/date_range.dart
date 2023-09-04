import 'package:any_date/src/extensions.dart';
import 'package:meta/meta.dart';

/// A range between two DateTime objects.
/// Inspired by Flutter > Material > DateTimeRange class
@immutable
class DateTimeRange {
  /// Creates a range for the given start and end values. [end] must be later
  /// than [start]
  DateTimeRange({
    required DateTime start,
    required DateTime end,
  }) : assert(!start.isAfter(end), 'start ($start) must be before end ($end)') {
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

  /// Start DateTime of this DateTimeRange.
  late final DateTime start;

  /// End DateTime of this DateTimeRange.
  late final DateTime end;

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [DateTime.difference] for more details.
  Duration get duration => end.difference(start);

  /// lazy iterable of all days in this range
  Iterable<DateTime> get days sync* {
    var d = start;
    while (!d.isAfter(end)) {
      yield d;
      d = d.nextDay;
    }
  }

  /// lazy iterable based on a given duration
  Iterable<DateTime> every(Duration duration) sync* {
    var d = start;
    while (d.isBefore(end)) {
      yield d;
      d = d.add(duration);
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
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => '$start - $end';
}
