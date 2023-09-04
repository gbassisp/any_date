import 'package:any_date/src/date_range.dart';
import 'package:test/test.dart';

void main() {
  group('date range', () {
    test('days getter', () {
      expect(
        DateTimeRange(start: DateTime(2000), end: DateTime(2001)).days,
        isNotEmpty,
      );
    });

    test('equality', () {
      final a = DateTimeRange(start: DateTime(2000), end: DateTime(2001));
      final b = DateTimeRange(start: DateTime(2000), end: DateTime(2001));

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.toString(), equals(b.toString()));
      expect(a, isNot(same(b)));
    });

    test('iterate every()', () {
      final a = DateTimeRange(
        start: DateTime(2000),
        end: DateTime(2001),
      );
      final b = a.every(const Duration(seconds: 1)).toSet();
      final c = a.duration.inSeconds;
      expect(b.length, equals(c));
    });
  });
}
