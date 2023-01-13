import 'package:any_date/src/date_range.dart';
import 'package:test/test.dart';

void main() {
  group('date range', () {
    test('days getter', () {
      expect(
        DateTimeRange(start: DateTime(2000), end: DateTime(2001)).days.length,
        isNot(0),
      );
    });
  });
}
