import 'package:any_date/any_date.dart';
import 'package:any_date/src/date_range.dart';
import 'package:test/test.dart';

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);
final range = DateTimeRange(start: DateTime(1999), end: DateTime(2005));
final singleDate = DateTime(2023, 1, 2, 3, 4, 5, 6, 7);
void main() {
  group('basic AnyDate().parse tests', () {
    test('matches DateTime.parse', () {
      final d = '$singleDate';

      expect(AnyDate().parse(d), DateTime.parse(d));
    });
    test('format exception', () {
      final d = 'not a date';

      expect(() => AnyDate().parse(d), throwsA(isA<FormatException>()));
    });
  });

  group(
    'exhaustive AnyDate().parse tests',
    () {
      test('matches DateTime.parse', () {
        final parser = AnyDate();
        int count = 0;
        for (var d in range.days) {
          expect(parser.parse('$d'), DateTime.parse('$d'));
          count++;
        }
        print('tested $count cases');
      });
      test('yyyy M d with / separator', () {
        final parser = AnyDate();
        int count = 0;
        for (var date in range.days) {
          String f = '${date.year}/${date.month}/${date.day}';
          print(f);
          expect(parser.parse(f), date);
          count++;
        }
        print('tested $count cases');
      });
      test('yyyy M d with multiple separators', () {
        final parser = AnyDate();
        final separators = parser.allowedSeparators;
        int count = 0;
        for (var date in range.days) {
          for (var a in separators) {
            for (var b in separators) {
              String f = '${date.year}$a${date.month}$b${date.day}';
              expect(parser.parse(f), date);
              count++;
            }
          }
        }
        print('tested $count cases');
      });
    },
    skip: !exhaustiveTests,
  );
}
